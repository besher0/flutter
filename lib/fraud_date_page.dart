import 'package:flutter/material.dart';

class FraudDatePage extends StatefulWidget {
  const FraudDatePage({super.key});

  @override
  State<FraudDatePage> createState() => _FraudDatePageState();
}

class _FraudDatePageState extends State<FraudDatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'لقد تم تعديل تاريخ الجهاز يرجى إعادته لوضعه الطبيعي ثم إعادة المحاولة',
        ),
      ),
    );
  }
}
