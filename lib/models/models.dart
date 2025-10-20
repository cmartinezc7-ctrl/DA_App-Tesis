import 'dart:convert';

enum QuestionType { multipleChoice, dragMatch, orderList }

QuestionType _qTypeFrom(String s) {
  switch (s) {
    case 'multiple': return QuestionType.multipleChoice;
    case 'drag': return QuestionType.dragMatch;
    case 'order': return QuestionType.orderList;
    default: return QuestionType.multipleChoice;
  }
}

class Question {
  final QuestionType type;
  final String prompt;
  final List<String>? choices;
  final int? correctIndex;
  final List<Map<String,String>>? pairs;
  final List<String>? order;

  Question({
    required this.type,
    required this.prompt,
    this.choices,
    this.correctIndex,
    this.pairs,
    this.order,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
    type: _qTypeFrom(j['type']),
    prompt: j['prompt'],
    choices: (j['choices'] as List?)?.map((e)=>e.toString()).toList(),
    correctIndex: j['correctIndex'],
    pairs: (j['pairs'] as List?)
        ?.map((e)=>{'left': e['left'].toString(), 'right': e['right'].toString()}).toList(),
    order: (j['order'] as List?)?.map((e)=>e.toString()).toList(),
  );
}

class Lesson {
  final String id;
  final String title;
  final String content;
  final List<Question> quiz;
  final int? minCorrect;

  Lesson({required this.id, required this.title, required this.content, required this.quiz, this.minCorrect});

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
    id: j['id'], title: j['title'], content: j['content'] ?? '',
    minCorrect: j['minCorrect'],
    quiz: (j['quiz'] as List).map((e)=>Question.fromJson(e)).toList(),
  );
}

class Level {
  final String id;
  final String title;
  final List<Lesson> lessons;

  Level({required this.id, required this.title, required this.lessons});

  factory Level.fromJson(Map<String, dynamic> j) => Level(
    id: j['id'], title: j['title'],
    lessons: (j['lessons'] as List).map((e)=>Lesson.fromJson(e)).toList(),
  );
}

class LevelBundle {
  final List<Level> levels;
  LevelBundle({required this.levels});
  factory LevelBundle.fromJson(Map<String, dynamic> j) =>
      LevelBundle(levels: (j['levels'] as List).map((e)=>Level.fromJson(e)).toList());

  static LevelBundle fromJsonStr(String s) => LevelBundle.fromJson(json.decode(s));
}
