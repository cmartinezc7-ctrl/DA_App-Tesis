import 'package:flutter/material.dart';
import '../data/levels_repo.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import 'quiz_player_view.dart';

class CoursesView extends StatefulWidget {
  static const route = '/courses';
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  late Future<List<Level>> _futureLevels;

  @override
  void initState() {
    super.initState();
    _futureLevels = LevelsRepo().load();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFFD),
      appBar: AppBar(
        title: const Text('Cursos'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Color(0xFF3A2E6E),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3A2E6E)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4EFFD), Color(0xFFEDE7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Level>>(
          future: _futureLevels,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final levels = snapshot.data ?? [];
            if (levels.isEmpty) {
              return const Center(child: Text('No hay niveles disponibles.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: levels.length + 1, // +1 para incluir el card hero
              itemBuilder: (context, i) {
                if (i == 0) return _heroCard(); // 💜 Card motivacional

                final lvl = levels[i - 1];
                return FutureBuilder<bool>(
                  future: ProgressService().isLevelUnlocked(lvl.id),
                  builder: (context, snap) {
                    final unlocked = snap.data == true;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: unlocked
                              ? _levelGradient(lvl.id)
                              : [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          leading: Icon(
                            unlocked
                                ? Icons.auto_awesome_rounded
                                : Icons.lock_outline_rounded,
                            color: unlocked
                                ? Colors.white
                                : Colors.grey.shade200,
                            size: 30,
                          ),
                          title: Text(
                            lvl.title,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: unlocked
                                  ? Column(
                                children: lvl.lessons
                                    .map(
                                      (lesson) => _LessonCard(
                                    lesson: lesson,
                                    level: lvl,
                                  ),
                                )
                                    .toList(),
                              )
                                  : Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Completa el nivel anterior para desbloquear este contenido.',
                                  style: text.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// 💡 Card hero motivacional — tonos distintos al resto
  Widget _heroCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¡Sigue aprendiendo!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cada curso te acerca más a dominar el análisis de datos.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/pregunta4.png', height: 95),
        ],
      ),
    );
  }

  /// 🎨 Gradientes personalizados por nivel
  List<Color> _levelGradient(String id) {
    switch (id) {
      case 'lvl1':
        return [const Color(0xFFFFB75E), const Color(0xFFED8F03)]; // naranja
      case 'lvl2':
        return [const Color(0xFF00B09B), const Color(0xFF96C93D)]; // verde
      case 'lvl3':
        return [const Color(0xFF6A11CB), const Color(0xFF2575FC)]; // violeta
      default:
        return [const Color(0xFF8E9EAB), const Color(0xFFEEF2F3)]; // gris
    }
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Level level;

  const _LessonCard({required this.lesson, required this.level});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLessonModal(context, level, lesson),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book_rounded,
                color: Color(0xFF6C63FF), size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A2E6E),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF6C63FF), size: 18),
          ],
        ),
      ),
    );
  }

  void _showLessonModal(BuildContext context, Level level, Lesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Icon(Icons.lightbulb_rounded,
                    color: Color(0xFF6C63FF), size: 48),
                const SizedBox(height: 10),
                Text(
                  lesson.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A2E6E),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lesson.content ?? 'Contenido no disponible.',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizPlayerView(level: level, lesson: lesson),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Practicar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
