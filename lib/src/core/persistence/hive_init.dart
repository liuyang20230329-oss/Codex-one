import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String preferences = 'preferences';
}

Future<void> initializeHive() async {
  await Hive.initFlutter();
}
