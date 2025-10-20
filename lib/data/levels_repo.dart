import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

class LevelsRepo {
  static final LevelsRepo _i = LevelsRepo._();
  LevelsRepo._();
  factory LevelsRepo() => _i;

  List<Level>? _cache;

  Future<List<Level>> load() async {
    if (_cache != null) return _cache!;
    final str = await rootBundle.loadString('assets/levels.json');
    _cache = LevelBundle.fromJsonStr(str).levels;
    return _cache!;
  }

  Future<Level?> getById(String id) async {
    final list = await load();
    try { return list.firstWhere((l)=>l.id==id); } catch (_) { return null; }
  }
}
