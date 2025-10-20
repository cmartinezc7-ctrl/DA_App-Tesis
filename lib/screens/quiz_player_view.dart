import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../widgets/questions.dart';

class QuizPlayerView extends StatefulWidget {
  final Level level;
  final Lesson lesson;
  const QuizPlayerView({super.key, required this.level, required this.lesson});

  @override
  State<QuizPlayerView> createState() => _QuizPlayerViewState();
}

class _QuizPlayerViewState extends State<QuizPlayerView> {
  int index = 0;
  int score = 0;

  // Temporizador
  static const int secondsPerQuestion = 30; // ajusta a gusto
  static const bool enableTimer = true;
  int secondsLeft = secondsPerQuestion;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!enableTimer) return;
    secondsLeft = secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) {
        t.cancel();
        _onAnswered(false); // tiempo agotado → incorrecta
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void _onAnswered(bool correct) {
    _timer?.cancel();
    if (correct) score++;
    if (index < widget.lesson.quiz.length - 1) {
      setState(() {
        index++;
        _startTimer();
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final total = widget.lesson.quiz.length;
    final minCorrect = widget.lesson.minCorrect ?? ((total * 0.7).ceil());
    final passed = score >= minCorrect;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(passed ? '¡Bien hecho!' : 'Sigue practicando'),
        content: Text('Puntuación: $score / $total\n'
            'Umbral de aprobación: $minCorrect'),
        actions: [
          if (!passed)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  index = 0; score = 0;
                  _startTimer();
                });
              },
              child: const Text('Reintentar'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(passed ? 'Continuar' : 'Salir'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (passed) {
      // marca lección
      await ProgressService().markLessonCompleted(widget.level.id, widget.lesson.id);
      // intenta desbloquear siguiente nivel
      final totalLessons = widget.level.lessons.length;
      final completed = await ProgressService().completedCountInLevel(widget.level.id);
      final nextLevelId = _inferNextLevelId(widget.level.id);
      await ProgressService().tryUnlockNextLevel(
        currentLvlId: widget.level.id,
        totalLessons: totalLessons,
        completedInLevel: completed,
        nextLevelId: nextLevelId,
      );
    }

    if (!mounted) return;
    Navigator.pop(context); // vuelve al detalle
  }

  String _inferNextLevelId(String current) {
    if (current == 'lvl1') return 'lvl2';
    if (current == 'lvl2') return 'lvl3';
    return '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.lesson.quiz[index];

    Widget body;
    switch (q.type) {
      case QuestionType.multipleChoice:
        body = MultipleChoiceQuestion(
          key: ValueKey('m_${index}'),
          prompt: q.prompt,
          choices: q.choices!,
          correctIndex: q.correctIndex!,
          onAnswered: _onAnswered,
        );
        break;
      case QuestionType.dragMatch:
        body = DragMatchQuestion(
          key: ValueKey('d_${index}'),
          prompt: q.prompt,
          pairs: q.pairs!,
          onAnswered: _onAnswered,
        );
        break;
      case QuestionType.orderList:
        body = OrderListQuestion(
          key: ValueKey('o_${index}'),
          prompt: q.prompt,
          items: q.order!,
          onAnswered: _onAnswered,
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${index + 1}/${widget.lesson.quiz.length}'),
        actions: [
          if (enableTimer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Center(child: Text('${secondsLeft}s')),
            )
        ],
        bottom: enableTimer
            ? PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: secondsLeft / secondsPerQuestion,
          ),
        )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Padding(padding: const EdgeInsets.all(16), child: body),
      ),
    );
  }
}
