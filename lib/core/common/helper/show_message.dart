import 'package:coursaty_student_and_teacher/core/platform/app_platform.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Root messenger of the app, for messages shown outside any page context.
abstract final class AppMessenger {
  static final key = GlobalKey<ScaffoldMessengerState>();
}

showMessage(
  String message, {
  bool hasError = true,
  Color? backGroundColor,
  Color? foreGroundColor,
  Toast timeShowing = Toast.LENGTH_LONG,
}) {
  if (message == 'null') return;
  // An empty message showed nothing at all, so the action looked ignored.
  final text = message.trim().isEmpty
      ? 'تعذر إتمام العملية، تحقق من الاتصال وأعد المحاولة'
      : message;
  // The toast plugin has no Windows version: desktop shows a SnackBar.
  if (AppPlatform.isDesktop) {
    final messenger = AppMessenger.key.currentState;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: TextStyle(color: foreGroundColor ?? const Color(0xff2661B2)),
          ),
          backgroundColor: backGroundColor ?? Colors.grey.shade300,
          behavior: SnackBarBehavior.floating,
          width: 420,
          duration: timeShowing == Toast.LENGTH_LONG
              ? const Duration(seconds: 4)
              : const Duration(seconds: 2),
        ),
      );
    return;
  }
  Fluttertoast.cancel().then(
    (value) => Fluttertoast.showToast(
      msg: text,
      backgroundColor: backGroundColor ?? Colors.grey.shade300,
      textColor: foreGroundColor ?? Color(0xff2661B2),
      fontSize: 16,
      toastLength: timeShowing,
      gravity: ToastGravity.BOTTOM,
    ),
  );
}
