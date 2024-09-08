import 'package:hive_flutter/hive_flutter.dart';

class Boxes{
  static Future<void> initHive() async {
    await Hive.openBox('ipNumber');
  }
  static Box get ipNumber => Hive.box('ipNumber');
}