import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/universal_image.dart';

class DetalleConductor extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> datos;

  const DetalleConductor({
    super.key,
    required this.uid,
    required this.datos,
  });

  @override
  State<DetalleConductor> createState() => _DetalleConductorState();
}

class _DetalleConductorState extends State<DetalleConductor> {
  final _dbRef = FirebaseDatabase.instance.ref();
  bool _cargando = false;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    final rawInfoVehiculo = widget.datos['infoVehiculo'];
    final infoVehiculo = rawInfoVehiculo is Map ? Map<String, dynamic>.from(rawInfoVehiculo) : null;
    final cat = infoVehiculo?['categoria']?.toString().toLowerCase() ?? 'economico';
    _categoriaSeleccionada = (cat == 'pendiente' || cat == 'n/a' || cat == 'n/A') ? 'economico' : cat;
  }

  void _verImagenAgrandada(String url) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: UniversalImage(url: url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: Text(
          '¿${nuevoEstado == 'aprobado' ? 'Aprobar' : 'Rechazar'} conductor?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          nuevoEstado == 'aprobado'
              ? 'El conductor podrá empezar a trabajar inmediatamente.'
              : 'El conductor no podrá usar la aplicación.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado == 'aprobado' ? const Color(0xFF10b981) : Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(nuevoEstado == 'aprobado' ? 'Aprobar' : 'Rechazar', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _cargando = true);
    try {
      await _dbRef.child('usuarios').child(widget.uid).update({
        'estadoValidacion': nuevoEstado,
        'fechaValidacion': ServerValue.timestamp,
        'infoVehiculo/categoria': _categoriaSeleccionada,
      });

      await _dbRef.child('conductores').child(widget.uid).update({
        'estadoValidacion': nuevoEstado,
        'categoria': _categoriaSeleccionada?.toLowerCase(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conductor $nuevoEstado exitosamente', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: nuevoEstado == 'aprobado' ? const Color(0xFF10b981) : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _guardarCategoria() async {
    setState(() => _cargando = true);
    try {
      await _dbRef.child('usuarios').child(widget.uid).update({
        'infoVehiculo/categoria': _categoriaSeleccionada,
      });
      await _dbRef.child('conductores').child(widget.uid).update({
        'categoria': _categoriaSeleccionada?.toLowerCase(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Categoría actualizada a ${_categoriaSeleccionada == 'economico' ? 'Económico' : 'Confort'}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF3b82f6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.datos['nombre'] ?? 'Sin nombre';
    final correo = widget.datos['correo'] ?? '';
    final telefono = widget.datos['telefono'] ?? '';
    final fotoPerfil = widget.datos['fotoPerfil'] ?? '';
    final fotoCedula = widget.datos['fotoCedula'] ?? '';
    final fotoLicencia = widget.datos['fotoLicencia'] ?? '';
    final estado = widget.datos['estadoValidacion'] ?? 'pendiente';

    final rawInfoVehiculo = widget.datos['infoVehiculo'];
    final infoVehiculo = rawInfoVehiculo is Map ? Map<String, dynamic>.from(rawInfoVehiculo) : null;

    final placa = infoVehiculo?['placa'] ?? 'N/A';
    final modelo = infoVehiculo?['modelo'] ?? 'N/A';
    final marca = infoVehiculo?['marca'] ?? 'N/A';
    final color = infoVehiculo?['color'] ?? 'N/A';
    final ano = infoVehiculo?['ano'] ?? 0;
    final tipo = infoVehiculo?['tipo'] ?? 'N/A';
    final aire = infoVehiculo?['aire'] ?? false;
    final musica = infoVehiculo?['musica'] ?? false;
    final imagenVehiculo = infoVehiculo?['imagenUrl'] ?? '';
    final registroVehicular = infoVehiculo?['registroVehicularUrl'] ?? '';

    final Color colorEstado = estado == 'aprobado'
        ? const Color(0xFF10b981)
        : estado == 'rechazado'
            ? Colors.redAccent
            : const Color(0xFFf59e0b);

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        title: Text('Perfil de Conductor', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1e293b),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white.withValues(alpha: 0.05), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _verImagenAgrandada(fotoPerfil),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorEstado, width: 4),
                        boxShadow: [
                          BoxShadow(color: colorEstado.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: ClipOval(
                        child: fotoPerfil.isNotEmpty
                            ? UniversalImage(url: fotoPerfil, fit: BoxFit.cover, width: 140, height: 140)
                            : Container(
                                color: const Color(0xFF0f172a),
                                child: const Icon(Icons.person, size: 70, color: Colors.white54),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nombre,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorEstado.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: colorEstado, size: 10),
                        const SizedBox(width: 8),
                        Text(
                          estado.toUpperCase(),
                          style: GoogleFonts.inter(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SeccionTitulo('Información Personal'),
                  _InfoCard([
                    _InfoRow(Icons.email_outlined, 'Correo', correo),
                    _InfoRow(Icons.phone_android, 'Teléfono', telefono),
                  ]),

                  const SizedBox(height: 32),
                  _SeccionTitulo('Documentos de Identidad'),
                  Row(
                    children: [
                      Expanded(child: _ImagenDocumento('Cédula', fotoCedula, onTap: () => _verImagenAgrandada(fotoCedula))),
                      const SizedBox(width: 16),
                      Expanded(child: _ImagenDocumento('Licencia', fotoLicencia, onTap: () => _verImagenAgrandada(fotoLicencia))),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _SeccionTitulo('Información del Vehículo'),
                  _InfoCard([
                    _InfoRow(tipo == 'Moto' ? Icons.two_wheeler : Icons.directions_car, 'Tipo', tipo),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.category_outlined, size: 20, color: Colors.white54),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 140,
                            child: Text(
                              'Categoría',
                              style: GoogleFonts.inter(color: Colors.white54, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0f172a),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _categoriaSeleccionada,
                                  dropdownColor: const Color(0xFF1e293b),
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                                  isExpanded: true,
                                  items: ['economico', 'confort']
                                      .map((String val) => DropdownMenuItem(
                                            value: val,
                                            child: Text(val == 'economico' ? 'Económico' : 'Confort'),
                                          ))
                                      .toList(),
                                  onChanged: (estado == 'pendiente' || estado == 'aprobado')
                                      ? (val) => setState(() => _categoriaSeleccionada = val)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _InfoRow(Icons.branding_watermark_outlined, 'Marca/Modelo', '$marca $modelo'),
                    _InfoRow(Icons.color_lens_outlined, 'Color/Año', '$color ($ano)'),
                    _InfoRow(Icons.pin_outlined, 'Placa', placa),
                    _InfoRow(Icons.ac_unit, 'Aire Acondicionado', aire ? 'Sí' : 'No'),
                    _InfoRow(Icons.speaker, 'Sistema de Audio', musica ? 'Sí' : 'No'),
                  ]),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _ImagenDocumento('Foto del Vehículo', imagenVehiculo, onTap: () => _verImagenAgrandada(imagenVehiculo))),
                      const SizedBox(width: 16),
                      Expanded(child: _ImagenDocumento('Registro Vehicular', registroVehicular, onTap: () => _verImagenAgrandada(registroVehicular))),
                    ],
                  ),

                  const SizedBox(height: 48),

                  if (estado == 'pendiente') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _cargando ? null : () => _cambiarEstado('aprobado'),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('APROBAR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10b981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _cargando ? null : () => _cambiarEstado('rechazado'),
                            icon: const Icon(Icons.cancel),
                            label: const Text('RECHAZAR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorEstado.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(estado == 'aprobado' ? Icons.check_circle : Icons.cancel, color: colorEstado, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Conductor $estado',
                              style: GoogleFonts.inter(color: colorEstado, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (estado == 'aprobado') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _cargando ? null : _guardarCategoria,
                          icon: const Icon(Icons.save),
                          label: const Text('GUARDAR CATEGORÍA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3b82f6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        titulo,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard(this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.white54, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagenDocumento extends StatelessWidget {
  final String titulo;
  final String url;
  final VoidCallback onTap;
  const _ImagenDocumento(this.titulo, this.url, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: url.isEmpty ? null : onTap,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0f172a),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: url.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, color: Colors.white.withValues(alpha: 0.2), size: 32),
                        const SizedBox(height: 8),
                        Text('No disponible', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        UniversalImage(url: url, fit: BoxFit.cover),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(Icons.zoom_out_map, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
