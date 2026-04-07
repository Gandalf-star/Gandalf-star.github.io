import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/universal_image.dart';

class DetallePasajero extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> datos;

  const DetallePasajero({
    super.key,
    required this.uid,
    required this.datos,
  });

  void _verImagenAgrandada(BuildContext context, String url) {
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

  @override
  Widget build(BuildContext context) {
    final nombre = datos['nombre'] ?? 'Sin nombre';
    final correo = datos['correo'] ?? datos['email'] ?? '';
    final telefono = datos['telefono'] ?? '';
    final fotoPerfil = datos['fotoPerfil'] ?? datos['fotoUrl'] ?? '';
    final fotoCedula = datos['fotoCedula'] ?? '';
    final fechaRegistro = datos['fechaRegistro'];

    String fechaTexto = 'No disponible';
    if (fechaRegistro != null) {
      final fecha = DateTime.fromMillisecondsSinceEpoch(fechaRegistro as int);
      fechaTexto = '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    }

    final Color colorAcento = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        title: Text('Perfil de Pasajero', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                    onTap: () => _verImagenAgrandada(context, fotoPerfil),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorAcento, width: 4),
                        boxShadow: [
                          BoxShadow(color: colorAcento.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
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
                      color: colorAcento.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorAcento.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_pin, color: colorAcento, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'PASAJERO',
                          style: GoogleFonts.inter(color: colorAcento, fontWeight: FontWeight.bold, fontSize: 12),
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
                  _SeccionTitulo('Información Personal', colorAcento),
                  _InfoCard([
                    _InfoRow(Icons.badge_outlined, 'Nombre', nombre),
                    _InfoRow(Icons.email_outlined, 'Correo', correo),
                    _InfoRow(Icons.phone_android, 'Teléfono', telefono),
                    _InfoRow(Icons.calendar_today_outlined, 'Fecha de Registro', fechaTexto),
                    _InfoRow(Icons.fingerprint, 'ID de Usuario', uid),
                  ]),

                  const SizedBox(height: 32),

                  if (datos.containsKey('totalViajes')) ...[
                    _SeccionTitulo('Estadísticas', colorAcento),
                    _InfoCard([
                      _InfoRow(Icons.route_outlined, 'Total de Viajes', datos['totalViajes'].toString()),
                      if (datos.containsKey('calificacionPromedio'))
                        _InfoRow(Icons.star_outline, 'Calificación Promedio', datos['calificacionPromedio'].toString()),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  if (fotoCedula.isNotEmpty) ...[
                    _SeccionTitulo('Documentos', colorAcento),
                    SizedBox(
                      width: double.infinity,
                      child: _ImagenDocumento(
                        'Cédula de Identidad',
                        fotoCedula,
                        onTap: () => _verImagenAgrandada(context, fotoCedula),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
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
  final Color colorAcento;
  const _SeccionTitulo(this.titulo, this.colorAcento);

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
            height: 200,
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
                          bottom: 12,
                          right: 12,
                          child: Icon(Icons.zoom_out_map, color: Colors.white, size: 24),
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
