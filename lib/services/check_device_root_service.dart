import 'package:root_checker_plus/root_checker_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class CheckDeviceRootService {
  static bool isDeviceHasRoot = false;
  static bool devModeEnabled = false;

  static Future<void> isDeviceRooted() async {
    if (Platform.isAndroid) {
      androidRootChecker();
      developerMode();
    } else {
      iosJailbreak();
    }
  }

  static Future<void> developerMode() async {
    try {
      devModeEnabled = (await RootCheckerPlus.isDeveloperMode())!;
    } on PlatformException {
      devModeEnabled = false;
    }
  }

  static Future<void> androidRootChecker() async {
    try {
      isDeviceHasRoot = (await RootCheckerPlus.isRootChecker())!;
    } on PlatformException {
      isDeviceHasRoot = false;
    }
  }

  static Future<void> iosJailbreak() async {
    try {
      isDeviceHasRoot = (await RootCheckerPlus.isJailbreak())!;
    } on PlatformException {
      isDeviceHasRoot = false;
    }
  }
}
