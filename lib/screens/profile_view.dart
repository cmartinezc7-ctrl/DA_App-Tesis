import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  double xp = 60; // experiencia actual
  double xpToNextLevel = 100; // XP necesaria
  int level = 3; // nivel actual
  late AnimationController _controller;
  late Animation<double> _xpAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _xpAnim = Tween<double>(begin: 0, end: xp / xpToNextLevel).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  void _gainXp(double amount) {
    setState(() {
      xp += amount;
      if (xp >= xpToNextLevel) {
        xp = xp - xpToNextLevel;
        level++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.deepPurple.shade400,
            content: Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.white),
                SizedBox(width: 10),
                Text('¡Subiste de nivel! 🎉', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      }
      _xpAnim = Tween<double>(begin: 0, end: xp / xpToNextLevel).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller.forward(from: 0);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedIn');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginView.route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFFD),
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Color(0xFF3A2E6E),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑 Tarjeta principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: math.pi / 10,
                        child: Icon(Icons.stars_rounded,
                            size: 110,
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 48, color: Color(0xFF6C63FF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Jean Carlos',
                      style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('jean.carlos@eduapp.com',
                      style: text.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 20),

                  // 🌟 Nivel + barra XP
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text('Nivel $level',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        const SizedBox(height: 6),
                        AnimatedBuilder(
                          animation: _xpAnim,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: _xpAnim.value,
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.amber),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('${xp.toInt()} XP / ${xpToNextLevel.toInt()} XP',
                            style: text.bodySmall
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () => _gainXp(20),
                    icon: const Icon(Icons.bolt, color: Colors.white),
                    label: const Text('Ganar XP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🏅 Insignias
            Text('Insignias',
                style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A2E6E))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Badge(icon: Icons.star, label: 'Primer paso', color: Color(0xFFFFC107)),
                _Badge(icon: Icons.analytics, label: 'Estrella del análisis', color: Color(0xFF6C63FF)),
                _Badge(icon: Icons.emoji_events, label: 'Nivel avanzado', color: Color(0xFF4CAF50)),
              ],
            ),
            const SizedBox(height: 32),

            // 🏆 Logros recientes
            Text('Logros recientes',
                style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A2E6E))),
            const SizedBox(height: 12),
            const _AchievementCard(
              title: 'Terminaste el nivel Fundamentos',
              subtitle: '5 lecciones completadas',
              daysAgo: 'Hace 2 días',
              icon: Icons.school,
              color: Color(0xFF6C63FF),
            ),
            const _AchievementCard(
              title: 'Has estudiado 3 días seguidos',
              subtitle: 'Excelente constancia',
              daysAgo: 'Hace 1 día',
              icon: Icons.local_fire_department,
              color: Color(0xFFFF7043),
            ),

            const SizedBox(height: 40),

            // 🚪 Botón de cerrar sesión
            Center(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 🏅 Badge Widget
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: text.bodySmall?.copyWith(
                color: const Color(0xFF3A2E6E),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// 🏆 Achievement card
class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String daysAgo;
  final IconData icon;
  final Color color;
  const _AchievementCard({
    required this.title,
    required this.subtitle,
    required this.daysAgo,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3A2E6E))),
                Text(subtitle,
                    style: text.bodySmall
                        ?.copyWith(color: Colors.black54, height: 1.2)),
                Text(daysAgo,
                    style: text.bodySmall
                        ?.copyWith(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
