// lib/screens/home_view.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import 'login_view.dart';

// NUEVO: imports para niveles/lecciones/progreso
import '../data/levels_repo.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import 'lessons_list_view.dart';

class HomeView extends StatefulWidget {
  static const route = '/home';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _index = 0;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedIn');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginView.route);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeTab(),
      const _CursosTab(),
      _PerfilTab(onLogout: _logout),
    ];

    return Scaffold(
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Cursos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

/// TAB DE INICIO (carga niveles desde assets y muestra estado)
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Future<List<Level>> _futureLevels;

  @override
  void initState() {
    super.initState();
    _futureLevels = LevelsRepo().load();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CurvedHeader(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, Christian',
                      style: text.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 4),
                  Text('¿Qué aprenderemos hoy?',
                      style: text.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(.9),
                      )),
                  const SizedBox(height: 16),

                  // Buscador + acción rápida
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar algún tema…',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune, color: AppColors.primary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Tarjeta "Aprender"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 120, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Descubre los nuevos\n temas en tendencia',
                                  style: text.titleMedium?.copyWith(
                                    color: const Color(0xFF2B2B2B),
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Aprender'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.asset('assets/mascot.png', height: 110),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Contenido principal
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFF4EFFD),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ruta de aprendizaje',
                    style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: const Color(0xFF3A2E6E))),
                const SizedBox(height: 12),

                // CARGA DINÁMICA DE NIVELES
                FutureBuilder<List<Level>>(
                  future: _futureLevels,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final levels = snapshot.data ?? [];
                    if (levels.isEmpty) {
                      return const Text('No se encontraron niveles.');
                    }

                    final children = <Widget>[];
                    for (int i = 0; i < levels.length; i++) {
                      final lvl = levels[i];
                      children.add(_LevelNodeAsync(level: lvl));
                      if (i < levels.length - 1) {
                        children.add(const _ArrowDown());
                      }
                    }
                    return Column(children: children);
                  },
                ),

                const SizedBox(height: 24),
                // Sugerencias rápidas
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: const [
                    _QuickChip(icon: Icons.play_circle_outline, label: 'Continuar'),
                    _QuickChip(icon: Icons.task_alt_outlined, label: 'Mis retos'),
                    _QuickChip(icon: Icons.leaderboard_outlined, label: 'Progreso'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CursosTab extends StatelessWidget {
  const _CursosTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cursos (próximamente)'));
  }
}

class _PerfilTab extends StatelessWidget {
  final Future<void> Function() onLogout;
  const _PerfilTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 12),
        const Text('Jean Carlos', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        )
      ]),
    );
  }
}

/// HEADER CURVO CON DEGRADADO
class _CurvedHeader extends StatelessWidget {
  final Widget child;
  const _CurvedHeader({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo degradado con curva inferior
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.bgTop, AppColors.bgBottom],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.only(top: 50, bottom: 16),
          child: child,
        ),
      ],
    );
  }
}

/// NODO DE NIVEL (con estado asíncrono de desbloqueo)
class _LevelNodeAsync extends StatelessWidget {
  final Level level;
  const _LevelNodeAsync({required this.level});

  Color _circleColor(String id) {
    if (id == 'lvl1') return const Color(0xFFFFE072);
    if (id == 'lvl2') return const Color(0xFF8E87FF);
    return const Color(0xFFBDBDBD);
    // Ajusta colores si agregaras más niveles
  }

  IconData _iconFor(String id, bool unlocked) {
    if (!unlocked) return Icons.lock_outline;
    if (id == 'lvl1') return Icons.search;
    if (id == 'lvl2') return Icons.analytics_outlined;
    return Icons.auto_graph;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FutureBuilder<bool>(
      future: ProgressService().isLevelUnlocked(level.id),
      builder: (context, snap) {
        final unlocked = snap.data == true;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar circular
            Container(
              height: 72, width: 72,
              decoration: BoxDecoration(
                color: _circleColor(level.id),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 8, offset: const Offset(0, 4),
                )],
              ),
              child: Icon(_iconFor(level.id, unlocked),
                  size: 30, color: unlocked ? Colors.black87 : Colors.white),
            ),
            const SizedBox(width: 12),
            // Texto + CTA
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10, offset: const Offset(0, 6),
                  )],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.title, style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: const Color(0xFF3A2E6E))),
                    const SizedBox(height: 2),
                    Text('5 lecciones', style: text.bodySmall?.copyWith(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(unlocked ? Icons.check_circle : Icons.lock,
                            size: 18, color: unlocked ? Colors.green : Colors.grey),
                        const SizedBox(width: 6),
                        Text(unlocked ? 'Disponible' : 'Bloqueado',
                            style: text.labelMedium?.copyWith(
                              color: unlocked ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w600,
                            )),
                        const Spacer(),
                        TextButton(
                          onPressed: unlocked
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LessonsListView(levelId: level.id),
                              ),
                            );
                          }
                              : null,
                          child: const Text('Ver'),
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
    );
  }
}

class _ArrowDown extends StatelessWidget {
  const _ArrowDown();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 28),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              children: List.generate(24, (i) => Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFB9B2F8),
                  margin: EdgeInsets.only(right: i == 23 ? 0 : 2),
                ),
              )),
            ),
          ),
          const Icon(Icons.arrow_downward, size: 18, color: Color(0xFF6C63FF)),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE7E3FF)),
    );
  }
}
