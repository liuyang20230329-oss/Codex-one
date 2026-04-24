import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'hive_init.dart';

class JsonPreferencesStore {
  JsonPreferencesStore(this._box);

  final Box<String> _box;

  static Future<JsonPreferencesStore> create() async {
    final box = await Hive.openBox<String>(HiveBoxes.preferences);
    return JsonPreferencesStore(box);
  }

  Future<Map<String, Object?>?> readObject(String key) async {
    return readObjectSync(key);
  }

  Map<String, Object?>? readObjectSync(String key) {
    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded.cast<String, Object?>();
    }
    return null;
  }

  Future<List<Object?>?> readList(String key) async {
    return readListSync(key);
  }

  List<Object?>? readListSync(String key) {
    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.cast<Object?>();
    }
    return null;
  }

  Future<void> writeJson(String key, Object? value) async {
    await _box.put(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }
}
