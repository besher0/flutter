import 'package:flutter/material.dart';

class OutdatedApp extends StatefulWidget {
  const OutdatedApp({super.key});

  @override
  State<OutdatedApp> createState() => _FraudDatePageState();
}

class _FraudDatePageState extends State<OutdatedApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('هذه النسخة لم تعد متاحة للاستخدام')),
    );
  }
}
