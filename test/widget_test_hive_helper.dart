import 'dart:io';
import 'dart:math';

import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

late JsonPreferencesStore _widgetTestStore;
late String _widgetTestHivePath;

Future<void> widgetTestSetUp() async {
  final id = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';
  _widgetTestHivePath = '${Directory.systemTemp.path}/hive_wt_$id';
  await Directory(_widgetTestHivePath).create(recursive: true);
  Hive.init(_widgetTestHivePath);
  _widgetTestStore = await JsonPreferencesStore.create();
}

JsonPreferencesStore get widgetTestStore => _widgetTestStore;

Future<void> widgetTestTearDown() async {
  try {
    await Hive.deleteBoxFromDisk('preferences');
  } catch (_) {}
  try {
    await Directory(_widgetTestHivePath).delete(recursive: true);
  } catch (_) {}
}
