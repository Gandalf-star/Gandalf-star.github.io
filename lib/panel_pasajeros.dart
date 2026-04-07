import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detalle_pasajero.dart';
import 'widgets/universal_image.dart';

class PanelPasajeros extends StatefulWidget {
  const PanelPasajeros({super.key});

  @override
  State<PanelPasajeros> createState() => _PanelPasajerosState();
}

class _PanelPasajerosState extends State<PanelPasajeros> {
  final _dbRef = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();
  String _busqueda = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dbRef.child('pasajeros').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        List<MapEntry<String, Map<String, dynamic>>> pasajerosFiltrados = [];
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        bool hasError = snapshot.hasError;
        bool noData = !snapshot.hasData || snapshot.data!.snapshot.value == null;

        if (!isLoading && !hasError && !noData) {
          final dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final usuarios = dataMap.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map)));
          pasajerosFiltrados = usuarios.entries.where((entry) {
            final datos = entry.value;

            if (_busqueda.isNotEmpty) {
              final nombre = (datos['nombre'] ?? '').toString().toLowerCase();
              final correo = (datos['correo'] ?? datos['email'] ?? '').toString().toLowerCase();
              final cedula = (datos['cedula'] ?? '').toString().toLowerCase();
              final telefono = (datos['telefono'] ?? '').toString().toLowerCase();
              return nombre.contains(_busqueda) || correo.contains(_busqueda) || cedula.contains(_busqueda) || telefono.contains(_busqueda);
            }
            return true;
          }).toList().map((e) => MapEntry(e.key, Map<String, dynamic>.from(e.value as Map))).toList();
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Directorio de Pasajeros',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar Pasajero por Nombre, Cédula o Correo...',
                        hintStyle: GoogleFonts.inter(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f172a),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => setState(() => _busqueda = value.toLowerCase()),
                    ),
                    if (!isLoading && !hasError && !noData) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'Total Pasajeros: ${pasajerosFiltrados.length}',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (hasError)
              SliverFillRemaining(
                child: Center(
                  child: Text('Error al cargar datos. Verifica permisos ($hasError)', style: GoogleFonts.inter(color: Colors.redAccent)),
                ),
              )
            else if (noData || pasajerosFiltrados.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        _busqueda.isEmpty ? 'No hay pasajeros registrados' : 'No se encontraron resultados para "$_busqueda"',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = pasajerosFiltrados[index];
                      return _PasajeroCard(uid: entry.key, datos: entry.value);
                    },
                    childCount: pasajerosFiltrados.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PasajeroCard extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> datos;

  const _PasajeroCard({required this.uid, required this.datos});

  @override
  Widget build(BuildContext context) {
    final nombre = datos['nombre'] ?? 'Sin nombre';
    final correo = datos['correo'] ?? datos['email'] ?? 'Sin correo';
    final telefono = datos['telefono'] ?? 'Sin teléfono';
    final fotoPerfil = datos['fotoPerfil'] ?? datos['fotoUrl'] ?? '';
    final fechaRegistro = datos['fechaRegistro'];

    String fechaStr = '';
    if (fechaRegistro != null) {
      final fecha = DateTime.fromMillisecondsSinceEpoch(fechaRegistro as int);
      fechaStr = '${fecha.day}/${fecha.month}/${fecha.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetallePasajero(uid: uid, datos: datos)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: ClipOval(
                    child: fotoPerfil.isNotEmpty
                        ? UniversalImage(url: fotoPerfil, fit: BoxFit.cover, width: 50, height: 50)
                        : Container(
                            color: const Color(0xFF0f172a),
                            child: const Icon(Icons.person, color: Colors.white54, size: 24),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: Colors.white54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              correo,
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (telefono.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_android, size: 14, color: Colors.white54),
                            const SizedBox(width: 6),
                            Text(telefono, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (fechaStr.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(fechaStr, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                      ),
                    const SizedBox(height: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
