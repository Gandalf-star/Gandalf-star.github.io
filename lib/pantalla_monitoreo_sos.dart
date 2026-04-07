import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/universal_image.dart';

class PantallaMonitoreoSOS extends StatefulWidget {
  const PantallaMonitoreoSOS({super.key});

  @override
  State<PantallaMonitoreoSOS> createState() => _PantallaMonitoreoSOSState();
}

class _PantallaMonitoreoSOSState extends State<PantallaMonitoreoSOS> {
  final _dbRef = FirebaseDatabase.instance.ref();
  GoogleMapController? _mapController;
  final Map<String, Marker> _markers = {};
  String? _selectedAlertId;

  // Estilo de mapa oscuro
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _seleccionarAlerta(String id, double lat, double lng) {
    setState(() {
      _selectedAlertId = id;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );
  }

  Future<void> _resolverAlerta(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: Text('¿Resolver Alerta?',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
            'Esta acción marcará la alerta como resuelta y la quitará del monitoreo activo.',
            style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981)),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _dbRef.child('alertas_emergencia').child(id).update({
        'estado': 'resuelta',
        'fecha_resolucion': ServerValue.timestamp,
      });
      if (_selectedAlertId == id) {
        setState(() => _selectedAlertId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Row(
        children: [
          // Sidebar de Alertas
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: const Color(0xFF1e293b),
              border: Border(
                  right:
                      BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency_share,
                          color: Colors.redAccent, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Alertas SOS',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: StreamBuilder(
                    stream: _dbRef
                        .child('alertas_emergencia')
                        .orderByChild('estado')
                        .equalTo('activa')
                        .onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.white24, size: 64),
                              const SizedBox(height: 16),
                              Text('No hay alertas activas',
                                  style: GoogleFonts.inter(
                                      color: Colors.white24, fontSize: 16)),
                            ],
                          ),
                        );
                      }

                      final Map<dynamic, dynamic> alertas =
                          snapshot.data!.snapshot.value as Map;
                      final listaAlertas = alertas.entries.toList()
                        ..sort((a, b) => (b.value['timestamp'] ?? 0)
                            .compareTo(a.value['timestamp'] ?? 0));

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: listaAlertas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final id = listaAlertas[index].key;
                          final data = Map<String, dynamic>.from(
                              listaAlertas[index].value);
                          final isSelected = _selectedAlertId == id;

                          return _AlertaTile(
                            id: id,
                            data: data,
                            isSelected: isSelected,
                            onTap: () => _seleccionarAlerta(
                                id,
                                (data['latitud'] as num?)?.toDouble() ?? 0.0,
                                (data['longitud'] as num?)?.toDouble() ?? 0.0),
                            onResolve: () => _resolverAlerta(id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Mapa y Detalles
          Expanded(
            child: Stack(
              children: [
                StreamBuilder(
                    stream: _dbRef
                        .child('alertas_emergencia')
                        .orderByChild('estado')
                        .equalTo('activa')
                        .onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      _markers.clear();
                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final Map<dynamic, dynamic> alertas =
                            snapshot.data!.snapshot.value as Map;
                        alertas.forEach((id, val) {
                          final data = Map<String, dynamic>.from(val);
                          _markers[id] = Marker(
                            markerId: MarkerId(id),
                            position: LatLng(
                                (data['latitud'] as num?)?.toDouble() ?? 0.0,
                                (data['longitud'] as num?)?.toDouble() ?? 0.0),
                            infoWindow: InfoWindow(
                                title: data['nombre'] ?? 'Sin nombre'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          );
                        });
                      }

                      return GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(9.35, -68.31), // Cojedes
                          zoom: 12,
                        ),
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(_markers.values),
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: false,
                        style: _mapStyle,
                      );
                    }),

                // Panel de detalles si hay una alerta seleccionada
                if (_selectedAlertId != null)
                  Positioned(
                    top: 24,
                    right: 24,
                    bottom: 24,
                    child: _DetalleAlertaPanel(
                      id: _selectedAlertId!,
                      dbRef: _dbRef,
                      onClose: () => setState(() => _selectedAlertId = null),
                      onResolve: () => _resolverAlerta(_selectedAlertId!),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertaTile extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onResolve;

  const _AlertaTile({
    required this.id,
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEF4444).withValues(alpha: 0.1)
              : const Color(0xFF0f172a).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEF4444)
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                  child: const Icon(Icons.person,
                      color: Colors.redAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nombre'] ?? 'Usuario Desconocido',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${id.substring(0, 8)}...',
                        style: GoogleFonts.inter(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onResolve,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10b981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Color(0xFF10b981), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (data['idViaje'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route, color: Colors.teal, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Viaje Activo',
                      style: GoogleFonts.inter(
                          color: Colors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _formatearFecha(data['timestamp']),
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - '
        '${date.day}/${date.month}';
  }
}

class _DetalleAlertaPanel extends StatelessWidget {
  final String id;
  final DatabaseReference dbRef;
  final VoidCallback onClose;
  final VoidCallback onResolve;

  const _DetalleAlertaPanel({
    required this.id,
    required this.dbRef,
    required this.onClose,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 10),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: StreamBuilder(
        stream: dbRef.child('alertas_emergencia').child(id).onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final idViaje = data['idViaje'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Detalle de Emergencia',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoSection(
                        title: 'USUARIO EN PELIGRO',
                        icon: Icons.person,
                        children: [
                          _DetailRow('Nombre', data['nombre']),
                          _DetailRow('ID Usuario', data['uid']),
                          _DetailRow('Rol', data['rol'] ?? 'N/A'),
                          _DetailRow('Coordenadas',
                              '${(data['latitud'] as num?)?.toDouble().toStringAsFixed(6) ?? 'N/A'}, ${(data['longitud'] as num?)?.toDouble().toStringAsFixed(6) ?? 'N/A'}'),
                        ],
                      ),
                      if (data['uid'] != null)
                        StreamBuilder(
                          stream: dbRef.child('usuarios').child(data['uid']).onValue,
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData || userSnapshot.data!.snapshot.value == null) {
                              return const SizedBox();
                            }
                            final userData = Map<String, dynamic>.from(userSnapshot.data!.snapshot.value as Map);
                            final telefono = userData['telefono']?.toString() ?? 'N/A';
                            final cedula = userData['cedula']?.toString() ?? userData['documento']?.toString() ?? 'N/A';
                            final fotoPerfil = userData['fotoPerfil']?.toString() ?? '';
                            final infoVehiculo = userData['infoVehiculo'] is Map ? Map<String, dynamic>.from(userData['infoVehiculo']) : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                if (fotoPerfil.isNotEmpty)
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.redAccent, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.redAccent.withValues(alpha: 0.2),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      ),
                                      child: ClipOval(
                                        child: UniversalImage(url: fotoPerfil, fit: BoxFit.cover, width: 100, height: 100),
                                      ),
                                    ),
                                  ),
                                _InfoSection(
                                  title: 'DATOS DE CONTACTO E ID',
                                  icon: Icons.contact_phone,
                                  children: [
                                    _DetailRow('Teléfono', telefono),
                                    _DetailRow('Cédula / Doc', cedula),
                                  ],
                                ),
                                if ((data['rol'] == 'conductor' || data['rol'] == 'Conductor') && infoVehiculo != null) ...[
                                  const SizedBox(height: 32),
                                  _InfoSection(
                                    title: 'INFORMACIÓN DEL VEHÍCULO',
                                    icon: Icons.directions_car,
                                    children: [
                                      _DetailRow('Placa', infoVehiculo['placa']?.toString()),
                                      _DetailRow('Marca / Modelo', '${infoVehiculo['marca'] ?? ''} ${infoVehiculo['modelo'] ?? ''}'),
                                      _DetailRow('Color', infoVehiculo['color']?.toString()),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 32),
                      if (idViaje != null) ...[
                        _InfoSection(
                          title: 'INFORMACIÓN DEL VIAJE',
                          icon: Icons.local_taxi,
                          children: [
                            _DetailRow('ID Viaje', idViaje),
                            StreamBuilder(
                              stream:
                                  dbRef.child('viajes').child(idViaje).onValue,
                              builder: (context, tripSnapshot) {
                                if (!tripSnapshot.hasData ||
                                    tripSnapshot.data!.snapshot.value == null) {
                                  return Text('Cargando datos del viaje...',
                                      style: GoogleFonts.inter(
                                          color: Colors.white54, fontSize: 13));
                                }
                                final tripData = Map<String, dynamic>.from(
                                    tripSnapshot.data!.snapshot.value as Map);
                                return Column(
                                  children: [
                                    _DetailRow(
                                        'Estado', tripData['estado'] ?? 'N/A'),
                                    _DetailRow('Desde',
                                        tripData['origen_direccion'] ?? 'N/A'),
                                    _DetailRow('Hacia',
                                        tripData['destino_direccion'] ?? 'N/A'),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      _InfoSection(
                        title: 'ACCIONES DE RESPUESTA',
                        icon: Icons.emergency,
                        children: [
                          const SizedBox(height: 12),
                          _ActionButton(
                            label: 'Llamar a Emergencias',
                            icon: Icons.phone_in_talk,
                            color: Colors.redAccent,
                            onTap:
                                () {}, // Integrar url_launcher si es necesario
                          ),
                          const SizedBox(height: 12),
                          _ActionButton(
                            label: 'Cancelar / Resolver Alerta',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF10b981),
                            onTap: onResolve,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoSection(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                  color: Colors.tealAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value ?? 'N/A',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
