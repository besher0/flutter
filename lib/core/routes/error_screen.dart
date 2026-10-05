import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({this.exception, Key? key}) : super(key: key);
  final GoException? exception;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(exception?.message ?? 'No Error Message')),
    );
  }
}
