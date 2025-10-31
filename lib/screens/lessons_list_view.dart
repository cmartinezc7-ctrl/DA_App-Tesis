import 'package:flutter/material.dart';
import '../data/levels_repo.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import 'quiz_player_view.dart';

class LessonsListView extends StatelessWidget {
  final String levelId;
  const LessonsListView({super.key, required this.levelId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Level?>(
      future: LevelsRepo().getById(levelId),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final level = snap.data!;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: const Color(0xFFF4EFFD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              level.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF3A2E6E),
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: level.lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final lesson = level.lessons[i];
              return FutureBuilder<bool>(
                future: ProgressService().isLessonCompleted(level.id, lesson.id),
                builder: (_, st) {
                  final done = st.data == true;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: done
                            ? [Colors.green.shade50, Colors.white]
                            : [Colors.white, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showLessonModal(context, level, lesson),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Hero(
                              tag: '${lesson.id}_icon',
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: done
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                child: Icon(
                                  done
                                      ? Icons.check_circle
                                      : Icons.menu_book_outlined,
                                  color: done
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3A2E6E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    done ? 'Completada' : 'Pendiente',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: done
                                          ? Colors.green.shade700
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF6C63FF),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showLessonModal(BuildContext context, Level level, Lesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LessonModal(level: level, lesson: lesson),
    );
  }
}

class _LessonModal extends StatelessWidget {
  final Level level;
  final Lesson lesson;
  const _LessonModal({required this.level, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),
          Hero(
            tag: '${lesson.id}_icon',
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE8E6FF),
              child: const Icon(Icons.auto_graph, color: Color(0xFF6C63FF), size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A2E6E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prepárate para responder preguntas y demostrar lo que sabes.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 600),
                  pageBuilder: (_, __, ___) =>
                      QuizPlayerView(level: level, lesson: lesson),
                  transitionsBuilder: (_, anim, __, child) {
                    return ScaleTransition(
                      scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                      child: child,
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 26),
            label: const Text(
              'Comenzar reto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
