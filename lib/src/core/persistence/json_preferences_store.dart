import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JsonPreferencesStore {
  JsonPreferencesStore(this._preferences);

  final SharedPreferences _preferences;

  static Future<JsonPreferencesStore> create() async {
    return JsonPreferencesStore(await SharedPreferences.getInstance());
  }

  Future<Map<String, Object?>?> readObject(String key) async {
    return readObjectSync(key);
  }

  Map<String, Object?>? readObjectSync(String key) {
    final raw = _preferences.getString(key);
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
    final raw = _preferences.getString(key);
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
    await _preferences.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
