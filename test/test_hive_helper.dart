import 'dart:io';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

late String _testHivePath;

Future<void> setUpTestHive() async {
  final id = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';
  _testHivePath = '${Directory.systemTemp.path}/hive_test_$id';
  await Directory(_testHivePath).create(recursive: true);
  Hive.init(_testHivePath);
}

Future<void> tearDownTestHive() async {
  try {
    await Hive.deleteBoxFromDisk('preferences');
  } catch (_) {}
  try {
    await Directory(_testHivePath).delete(recursive: true);
  } catch (_) {}
}
