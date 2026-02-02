import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingApiService {
  static const MethodChannel _channel = MethodChannel(
    'com.fitness_tracker.android/recording_api',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.fitness_tracker.android/step_stream',
  );

  static final RecordingApiService _instance = RecordingApiService._internal();
  factory RecordingApiService() => _instance;
  RecordingApiService._internal();

  Future<bool> requestPermission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<bool> checkPlayServices() async {
    try {
      final bool? available = await _channel.invokeMethod('checkPlayServices');
      return available ?? false;
    } on PlatformException catch (e) {
      print("Failed to check Play Services: ${e.message}");
      return false;
    }
  }

  Future<bool> subscribe() async {
    try {
      final bool? success = await _channel.invokeMethod('subscribe');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Failed to subscribe: ${e.message}");
      return false;
    }
  }

  Future<bool> unsubscribe() async {
    try {
      final bool? success = await _channel.invokeMethod('unsubscribe');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Failed to unsubscribe: ${e.message}");
      return false;
    }
  }

  Future<int> readSteps() async {
    try {
      final int? steps = await _channel.invokeMethod('readSteps');
      return steps ?? 0;
    } on PlatformException catch (e) {
      print("Failed to read steps: ${e.message}");
      return 0;
    }
  }

  Stream<int> get stepStream {
    return _eventChannel.receiveBroadcastStream().map((event) => event as int);
  }
}
