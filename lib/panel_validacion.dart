import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detalle_conductor.dart';
import 'widgets/universal_image.dart';

class PanelValidacion extends StatefulWidget {
  const PanelValidacion({super.key});

  @override
  State<PanelValidacion> createState() => _PanelValidacionState();
}

class _PanelValidacionState extends State<PanelValidacion> {
  final _dbRef = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();

  String _filtro = 'pendiente'; // 'todos', 'pendiente', 'aprobado', 'rechazado'
  String _busqueda = '';
  String _filtroServicio = 'todos';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dbRef.child('usuarios').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        List<MapEntry<String, Map<String, dynamic>>> conductoresFiltrados = [];
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        bool hasError = snapshot.hasError;
        bool noData =
            !snapshot.hasData || snapshot.data!.snapshot.value == null;

        if (!isLoading && !hasError && !noData) {
          final dataMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final usuarios = dataMap.map((key, value) => MapEntry(
              key.toString(), Map<String, dynamic>.from(value as Map)));
          conductoresFiltrados = usuarios.entries
              .where((entry) {
                final datos = entry.value;
                final rol = (datos['rol'] ?? '').toString();
                if (rol != 'conductor') return false;
                final estado = datos['estadoValidacion'] ?? 'pendiente';
                if (_filtro != 'todos' && estado != _filtro) return false;

                if (_busqueda.isNotEmpty) {
                  final nombre =
                      (datos['nombre'] ?? '').toString().toLowerCase();
                  final correo =
                      (datos['correo'] ?? '').toString().toLowerCase();
                  final cedula =
                      (datos['cedula'] ?? '').toString().toLowerCase();
                  final infoVehiculo = datos['infoVehiculo'] as Map?;
                  final placa =
                      (infoVehiculo?['placa'] ?? '').toString().toLowerCase();
                  if (!nombre.contains(_busqueda) &&
                      !correo.contains(_busqueda) &&
                      !cedula.contains(_busqueda) &&
                      !placa.contains(_busqueda)) {
                    return false;
                  }
                }

                if (_filtroServicio != 'todos') {
                  final infoVehiculo = datos['infoVehiculo'] as Map?;
                  final tipo = (infoVehiculo?['tipo'] ?? '').toString();
                  if (tipo != _filtroServicio) return false;
                }
                return true;
              })
              .toList()
              .map((e) =>
                  MapEntry(e.key, Map<String, dynamic>.from(e.value as Map)))
              .toList();
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
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validación de Conductores',
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
                        hintText:
                            'Buscar por Nombre, Cédula, Placa o Correo...',
                        hintStyle: GoogleFonts.inter(color: Colors.white54),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f172a),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) =>
                          setState(() => _busqueda = value.toLowerCase()),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FiltroChip(
                            label: 'Pendientes',
                            selected: _filtro == 'pendiente',
                            onSelected: (b) =>
                                setState(() => _filtro = 'pendiente'),
                            color: const Color(0xFFf59e0b),
                          ),
                          const SizedBox(width: 8),
                          _FiltroChip(
                            label: 'Aprobados',
                            selected: _filtro == 'aprobado',
                            onSelected: (b) =>
                                setState(() => _filtro = 'aprobado'),
                            color: const Color(0xFF10b981),
                          ),
                          const SizedBox(width: 8),
                          _FiltroChip(
                            label: 'Rechazados',
                            selected: _filtro == 'rechazado',
                            onSelected: (b) =>
                                setState(() => _filtro = 'rechazado'),
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          _FiltroChip(
                            label: 'Todos',
                            selected: _filtro == 'todos',
                            onSelected: (b) =>
                                setState(() => _filtro = 'todos'),
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 24),
                          Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.1)),
                          const SizedBox(width: 24),
                          _FiltroChip(
                            label: 'Motos',
                            selected: _filtroServicio == 'Moto',
                            onSelected: (b) => setState(
                                () => _filtroServicio = b ? 'Moto' : 'todos'),
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icons.two_wheeler,
                          ),
                          const SizedBox(width: 8),
                          _FiltroChip(
                            label: 'Carros',
                            selected: _filtroServicio == 'Carro',
                            onSelected: (b) => setState(
                                () => _filtroServicio = b ? 'Carro' : 'todos'),
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icons.directions_car,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (hasError)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                      'Error al cargar datos. Verifica permisos ($hasError)',
                      style: GoogleFonts.inter(color: Colors.redAccent)),
                ),
              )
            else if (noData || conductoresFiltrados.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        noData
                            ? 'No hay conductores registrados'
                            : 'No se encontraron resultados',
                        style: GoogleFonts.inter(
                            fontSize: 18, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = conductoresFiltrados[index];
                      return _ConductorCard(uid: entry.key, datos: entry.value);
                    },
                    childCount: conductoresFiltrados.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final Color color;
  final IconData? icon;

  const _FiltroChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: icon == null
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: selected ? Colors.white : color),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: const Color(0xFF0f172a),
      selectedColor: color.withValues(alpha: 0.8),
      labelStyle: GoogleFonts.inter(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1)),
      ),
      showCheckmark: false,
    );
  }
}

class _ConductorCard extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> datos;

  const _ConductorCard({required this.uid, required this.datos});

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'aprobado':
        return const Color(0xFF10b981);
      case 'rechazado':
        return Colors.redAccent;
      default:
        return const Color(0xFFf59e0b);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = datos['nombre'] ?? 'Sin nombre';
    final correo = datos['correo'] ?? 'Sin correo';
    final cedula = datos['cedula'] ?? 'Sin cédula';
    final fotoPerfil = datos['fotoPerfil'] ?? '';
    final estado = datos['estadoValidacion'] ?? 'pendiente';

    final rawInfoVehiculo = datos['infoVehiculo'];
    final infoVehiculo = rawInfoVehiculo is Map
        ? Map<String, dynamic>.from(rawInfoVehiculo)
        : null;
    final tipo = infoVehiculo?['tipo'] ?? 'N/A';
    final categoria = infoVehiculo?['categoria'] ?? 'N/A';
    final placa = infoVehiculo?['placa'] ?? 'N/A';

    final colorEstado = _getColorEstado(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DetalleConductor(uid: uid, datos: datos)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colorEstado.withValues(alpha: 0.5), width: 3),
                  ),
                  child: ClipOval(
                    child: fotoPerfil.isNotEmpty
                        ? UniversalImage(
                            url: fotoPerfil,
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64)
                        : Container(
                            width: 64,
                            height: 64,
                            color: const Color(0xFF0f172a),
                            child: const Icon(Icons.person,
                                size: 32, color: Colors.white54),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tipo == 'Moto'
                                      ? Icons.two_wheeler
                                      : Icons.directions_car,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$tipo $categoria',
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.badge_outlined,
                                  size: 14, color: Colors.white54),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('C.I: $cedula',
                                    style: GoogleFonts.inter(
                                        color: Colors.white70, fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pin_outlined,
                                  size: 14, color: Colors.white54),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('Placa: $placa',
                                    style: GoogleFonts.inter(
                                        color: Colors.white70, fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(correo,
                          style: GoogleFonts.inter(
                              color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.chevron_right, color: colorEstado),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
