import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'panel_validacion.dart';
import 'panel_pasajeros.dart';
import 'pantalla_monitoreo_sos.dart';

class DashboardPrincipal extends StatefulWidget {
  const DashboardPrincipal({super.key});

  @override
  State<DashboardPrincipal> createState() => _DashboardPrincipalState();
}

class _DashboardPrincipalState extends State<DashboardPrincipal> {
  int _selectedIndex = 0;

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _navegarA(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    final bodyContent = IndexedStack(
      index: _selectedIndex,
      children: [
        _DashboardHome(onNavegar: _navegarA),
        const PanelValidacion(),
        const PanelPasajeros(),
        const PantallaMonitoreoSOS(),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _SideMenu(
              selectedIndex: _selectedIndex,
              onNavigate: _navegarA,
              onLogout: _cerrarSesion,
            ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(onLogout: _cerrarSesion),
                  Expanded(child: bodyContent),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Click Admin',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0f172a),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: const Color(0xFF1e293b),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Panel Admin',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      _navegarA(0);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.drive_eta_outlined,
                    label: 'Conductores',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      _navegarA(1);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Pasajeros',
                    isSelected: _selectedIndex == 2,
                    onTap: () {
                      _navegarA(2);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.emergency_share_outlined,
                    label: 'Monitoreo SOS',
                    isSelected: _selectedIndex == 3,
                    onTap: () {
                      _navegarA(3);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Cerrar Sesión',
              isSelected: false,
              color: Colors.redAccent,
              onTap: _cerrarSesion,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      body: bodyContent,
    );
  }
}

class _SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavigate;
  final VoidCallback onLogout;

  const _SideMenu({
    required this.selectedIndex,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: const Color(0xFF1e293b),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  'Click Admin',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _MenuItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => onNavigate(0),
                ),
                _MenuItem(
                  icon: Icons.drive_eta_outlined,
                  activeIcon: Icons.drive_eta,
                  label: 'Conductores',
                  isSelected: selectedIndex == 1,
                  onTap: () => onNavigate(1),
                ),
                _MenuItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Pasajeros',
                  isSelected: selectedIndex == 2,
                  onTap: () => onNavigate(2),
                ),
                _MenuItem(
                  icon: Icons.emergency_share_outlined,
                  activeIcon: Icons.emergency_share,
                  label: 'Monitoreo SOS',
                  isSelected: selectedIndex == 3,
                  onTap: () => onNavigate(3),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f172a),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF10b981),
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          FirebaseAuth.instance.currentUser?.email ?? '',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('Cerrar Sesión'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white54,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white70,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ??
        (isSelected ? Theme.of(context).colorScheme.primary : Colors.white70);
    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: effectiveColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onLogout;
  const _TopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Panel de Control',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white70,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Administrador',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  final Function(int) onNavegar;
  const _DashboardHome({required this.onNavegar});

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref();
    final size = MediaQuery.of(context).size;
    final inRow = size.width > 1200 ? 4 : (size.width > 800 ? 2 : 1);

    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visión General',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitoreo en tiempo real de actividades en Click',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white54),
            ),
            const SizedBox(height: 48),

            // Estadísticas
            StreamBuilder(
              stream: dbRef.child('usuarios').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshotUsuarios) {
                return StreamBuilder(
                  stream: dbRef.child('pasajeros').onValue,
                  builder:
                      (
                        context,
                        AsyncSnapshot<DatabaseEvent> snapshotPasajeros,
                      ) {
                        if (snapshotUsuarios.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshotUsuarios.hasError ||
                            snapshotPasajeros.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Error de permisos en Firebase. Asegúrate de configurar las Reglas de Realtime Database para permitir el acceso al administrador.',
                                    style: GoogleFonts.inter(
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final usuariosMap =
                            snapshotUsuarios.hasData &&
                                snapshotUsuarios.data!.snapshot.value != null
                            ? Map<String, dynamic>.from(
                                snapshotUsuarios.data!.snapshot.value as Map,
                              )
                            : {};

                        final pasajerosMap =
                            snapshotPasajeros.hasData &&
                                snapshotPasajeros.data?.snapshot.value != null
                            ? Map<String, dynamic>.from(
                                snapshotPasajeros.data!.snapshot.value as Map,
                              )
                            : {};

                        int conductoresPendientes = 0;
                        int conductoresAprobados = 0;
                        int conductoresRechazados = 0;

                        usuariosMap.forEach((key, value) {
                          final datos = Map<String, dynamic>.from(value as Map);
                          final rol = datos['rol'] ?? '';
                          if (rol == 'conductor') {
                            // Prioridad: usar estadoConductor.aprobado, fallback a estadoValidacion
                            final estadoConductor = datos['estadoConductor'] as Map?;
                            final aprobado = estadoConductor?['aprobado'] ?? false;
                            final estadoValidacion = datos['estadoValidacion'] ?? 'pendiente';
                            
                            // Determinar estado basado en aprobado
                            String estado;
                            if (aprobado == true) {
                              estado = 'aprobado';
                            } else if (estadoValidacion == 'rechazado') {
                              estado = 'rechazado';
                            } else {
                              estado = 'pendiente';
                            }
                            
                            if (estado == 'pendiente') {
                              conductoresPendientes++;
                            } else if (estado == 'aprobado') {
                              conductoresAprobados++;
                            } else if (estado == 'rechazado') {
                              conductoresRechazados++;
                            }
                          }
                        });

                        int totalPasajeros = pasajerosMap.length;
                        final totalConductores =
                            conductoresPendientes +
                            conductoresAprobados +
                            conductoresRechazados;

                        final cards = [
                          _StatCard(
                            title: 'Total Conductores',
                            value: totalConductores.toString(),
                            subtitle: 'Click_v2',
                            icon: Icons.drive_eta,
                            gradient: const [
                              Color(0xFF3b82f6),
                              Color(0xFF2563eb),
                            ],
                          ),
                          _StatCard(
                            title: 'Total Pasajeros',
                            value: totalPasajeros.toString(),
                            subtitle: 'ClickExpress',
                            icon: Icons.people,
                            gradient: const [
                              Color(0xFF8b5cf6),
                              Color(0xFF6d28d9),
                            ],
                          ),
                          _StatCard(
                            title: 'Pendientes',
                            value: conductoresPendientes.toString(),
                            subtitle: 'Requieren validación',
                            icon: Icons.pending_actions,
                            gradient: const [
                              Color(0xFFf59e0b),
                              Color(0xFFd97706),
                            ],
                          ),
                          _StatCard(
                            title: 'Aprobados',
                            value: conductoresAprobados.toString(),
                            subtitle: 'Listos para viajar',
                            icon: Icons.check_circle_outline,
                            gradient: const [
                              Color(0xFF10b981),
                              Color(0xFF059669),
                            ],
                          ),
                        ];

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: inRow,
                                childAspectRatio: inRow == 1 ? 2.5 : 1.6,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                              ),
                          itemCount: cards.length,
                          itemBuilder: (context, index) => cards[index],
                        );
                      },
                );
              },
            ),

            const SizedBox(height: 48),
            Text(
              'Acciones Rápidas',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Validación',
                    description: 'Revisar documentos de conductores',
                    icon: Icons.assignment_turned_in,
                    color: const Color(0xFFf59e0b),
                    onTap: () => widget.onNavegar(1),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Usuarios',
                    description: 'Directorio general de pasajeros',
                    icon: Icons.groups,
                    color: const Color(0xFF3b82f6),
                    onTap: () => widget.onNavegar(2),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Seguridad SOS',
                    description: 'Monitoreo de emergencias en vivo',
                    icon: Icons.emergency_share,
                    color: Colors.redAccent,
                    onTap: () => widget.onNavegar(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 100,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1e293b),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
