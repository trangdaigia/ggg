import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveService<T> {
  HiveService({required this.name});
  final String name;

  Future<void> save(String key, T value) async {
    try {
      final box = await _openBox();
      await box.put(key, value);
      print("Saved data to box $name with key $key");
    } catch (e) {
      debugPrint("Error saving data to Hive: $e");
    }
  }

  Future<T?> readData(String key) async {
    try {
      final box = await _openBox();
      print("Read data from Hive: $name with key: $key");
      return box.get(key);
    } catch (e) {
      debugPrint("Error reading data from Hive: $e");
      return null;
    }
  }

  Future<Box<T>> _openBox() async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<T>(name);
    }
    return Hive.box<T>(name);
  }

  void deleteBox(String key) {
    try {
      if (Hive.isBoxOpen(name)) {
        Hive.box<T>(name).delete(key);
        print("Deleted key $key from box $name");
      }
    } catch (e) {
      debugPrint("Error deleting box: $e");
    }
  }
}