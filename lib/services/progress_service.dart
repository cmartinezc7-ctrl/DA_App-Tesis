import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _kCompletedLessons = 'completed_lessons'; // lvl:lesson
  static const _kUnlockedLevels  = 'unlocked_levels';    // lvl

  Future<List<String>> _getList(String k) async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(k) ?? [];
  }

  Future<void> _setList(String k, List<String> v) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(k, v);
  }

  Future<bool> isLessonCompleted(String lvlId, String lessonId) async {
    final list = await _getList(_kCompletedLessons);
    return list.contains('$lvlId:$lessonId');
  }

  Future<int> completedCountInLevel(String lvlId) async {
    final list = await _getList(_kCompletedLessons);
    return list.where((e)=>e.startsWith('$lvlId:')).length;
  }

  Future<void> markLessonCompleted(String lvlId, String lessonId) async {
    final list = await _getList(_kCompletedLessons);
    final key = '$lvlId:$lessonId';
    if (!list.contains(key)) {
      list.add(key);
      await _setList(_kCompletedLessons, list);
    }
  }

  Future<bool> isLevelUnlocked(String lvlId) async {
    // lvl1 siempre desbloqueado
    if (lvlId == 'lvl1') return true;
    final list = await _getList(_kUnlockedLevels);
    return list.contains(lvlId);
  }

  Future<void> tryUnlockNextLevel({
    required String currentLvlId,
    required int totalLessons,
    required int completedInLevel,
    required String nextLevelId,
  }) async {
    if (nextLevelId.isEmpty) return;
    if (completedInLevel >= totalLessons) {
      final list = await _getList(_kUnlockedLevels);
      if (!list.contains(nextLevelId)) {
        list.add(nextLevelId);
        await _setList(_kUnlockedLevels, list);
      }
    }
  }
}
