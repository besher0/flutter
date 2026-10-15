import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
