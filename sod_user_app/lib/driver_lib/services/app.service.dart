import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:singleton/singleton.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AppService {
  //

  /// Factory method that reuse same instance automatically
  factory AppService() => Singleton.lazy(() => AppService._());

  /// Private constructor
  AppService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BehaviorSubject<int> homePageIndex = BehaviorSubject<int>();
  BehaviorSubject<bool> refreshAssignedOrders = BehaviorSubject<bool>();
  BehaviorSubject<Order> addToAssignedOrders = BehaviorSubject<Order>();
  bool driverIsOnline = false;
  StreamSubscription? actionStream;
  List<int> ignoredOrders = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  changeHomePageIndex({int index = 2}) async {
    print("Changed Home Page");
    homePageIndex.add(index);
  }

  void playNotificationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset("assets/audio/alert_louder_cut.mp3");
      _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.setSpeed(1.4);
      await _audioPlayer.play();
    } catch (error) {
      print("Error playing audio: $error");
    }
  }

  void stopNotificationSound() async {
    try {
      await _audioPlayer.stop();
    } catch (error) {
      print("Error stopping audio: $error");
    }
  }

  Future<File?> compressFile(File file, {int quality = 50}) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        dir.absolute.path + "/temp_" + randomAlphaNumeric(10) + ".jpg";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    print("File size ==> ${file.lengthSync()}");
    print("Compressed File size ==> ${result?.lengthSync()}");
    return result;
  }
}
