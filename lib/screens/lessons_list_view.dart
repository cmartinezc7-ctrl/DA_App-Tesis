import 'package:flutter/material.dart';
import '../data/levels_repo.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import 'lesson_detail_view.dart';

class LessonsListView extends StatelessWidget {
  final String levelId;
  const LessonsListView({super.key, required this.levelId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Level?>(
      future: LevelsRepo().getById(levelId),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final level = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(level.title)),
          body: ListView.separated(
            itemCount: level.lessons.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final lesson = level.lessons[i];
              return FutureBuilder<bool>(
                future: ProgressService().isLessonCompleted(level.id, lesson.id),
                builder: (_, st) {
                  final done = st.data == true;
                  return ListTile(
                    title: Text(lesson.title),
                    subtitle: Text(done ? 'Completada' : 'Pendiente'),
                    trailing: Icon(done ? Icons.check_circle : Icons.chevron_right,
                        color: done ? Colors.green : null),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LessonDetailView(level: level, lesson: lesson))),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
