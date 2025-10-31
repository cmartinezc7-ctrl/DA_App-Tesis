import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

class _QuizPlayerViewState extends State<QuizPlayerView>
    with TickerProviderStateMixin {
  int index = 0;
  int score = 0;

  static const int secondsPerQuestion = 30;
  static const bool enableTimer = true;
  int secondsLeft = secondsPerQuestion;
  Timer? _timer;

  final AudioPlayer _player = AudioPlayer();
  late AnimationController _resultAnimController;
  late Animation<double> _resultAnim;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _resultAnim = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.elasticOut,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    if (!enableTimer) return;
    secondsLeft = secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) {
        t.cancel();
        _onAnswered(false);
      } else {
        if (mounted) {
          setState(() => secondsLeft--);
        }
      }
    });
  }

  Future<void> _playSound(String file) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$file.mp3'));
    } catch (_) {}
  }

  void _onAnswered(bool correct) {
    _timer?.cancel();
    if (correct) {
      score++;
      _playSound('correct');
    } else {
      _playSound('wrong');
    }

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

    if (passed) {
      _playSound('win');
    } else {
      _playSound('lose');
    }

    _resultAnimController.forward(from: 0);

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => ScaleTransition(
        scale: _resultAnim,
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  passed
                      ? Icons.emoji_events_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  size: 70,
                  color:
                  passed ? Colors.amber.shade700 : Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? '¡Felicidades!' : 'Sigue intentándolo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color:
                    passed ? const Color(0xFF4CAF50) : const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Puntuación: $score / $total',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mínimo requerido: $minCorrect',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                if (!passed)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        index = 0;
                        score = 0;
                        _startTimer();
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    _timer?.cancel();
                    await _player.stop();
                    if (mounted) {
                      Navigator.pop(context); // Cierra el diálogo
                      Navigator.pop(context); // Sale del quiz
                    }
                  },
                  icon: Icon(
                    passed
                        ? Icons.arrow_forward_rounded
                        : Icons.exit_to_app_rounded,
                  ),
                  label: Text(passed ? 'Continuar' : 'Salir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    passed ? Colors.green.shade600 : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (passed) {
      await ProgressService()
          .markLessonCompleted(widget.level.id, widget.lesson.id);
      final totalLessons = widget.level.lessons.length;
      final completed =
      await ProgressService().completedCountInLevel(widget.level.id);
      final nextLevelId = _inferNextLevelId(widget.level.id);
      await ProgressService().tryUnlockNextLevel(
        currentLvlId: widget.level.id,
        totalLessons: totalLessons,
        completedInLevel: completed,
        nextLevelId: nextLevelId,
      );
    }
  }

  String _inferNextLevelId(String current) {
    if (current == 'lvl1') return 'lvl2';
    if (current == 'lvl2') return 'lvl3';
    return '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.lesson.quiz[index];

    Widget body;
    switch (q.type) {
      case QuestionType.multipleChoice:
        body = MultipleChoiceQuestion(
          key: ValueKey('m_$index'),
          prompt: q.prompt,
          choices: q.choices!,
          correctIndex: q.correctIndex!,
          onAnswered: _onAnswered,
        );
        break;
      case QuestionType.dragMatch:
        body = DragMatchQuestion(
          key: ValueKey('d_$index'),
          prompt: q.prompt,
          pairs: q.pairs!,
          onAnswered: _onAnswered,
        );
        break;
      case QuestionType.orderList:
        body = OrderListQuestion(
          key: ValueKey('o_$index'),
          prompt: q.prompt,
          items: q.order!,
          onAnswered: _onAnswered,
        );
        break;
    }

    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        await _player.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFFD),
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          title: Text(
            'Pregunta ${index + 1}/${widget.lesson.quiz.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF3A2E6E),
            ),
          ),
          actions: [
            if (enableTimer)
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 18),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${secondsLeft}s',
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
          bottom: enableTimer
              ? PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: secondsLeft / secondsPerQuestion,
              color: const Color(0xFF6C63FF),
              backgroundColor: const Color(0xFFE8E6FF),
            ),
          )
              : null,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: Padding(
            key: ValueKey(index),
            padding: const EdgeInsets.all(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
