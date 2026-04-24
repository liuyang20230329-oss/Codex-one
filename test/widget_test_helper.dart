import 'dart:io';
import 'dart:math';

import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<JsonPreferencesStore> createTestStore(WidgetTester tester) async {
  final id = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';
  final dir = Directory('${Directory.systemTemp.path}/hive_wt_$id');
  await dir.create(recursive: true);
  Hive.init(dir.path);
  return JsonPreferencesStore.create();
}
