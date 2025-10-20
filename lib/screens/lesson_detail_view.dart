import 'package:flutter/material.dart';
import '../models/models.dart';
import 'quiz_player_view.dart';

class LessonDetailView extends StatelessWidget {
  final Level level;
  final Lesson lesson;
  const LessonDetailView({super.key, required this.level, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(lesson.content))),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => QuizPlayerView(level: level, lesson: lesson))),
              label: const Text('Resolver preguntas'),
            ),
          ],
        ),
      ),
    );
  }
}
