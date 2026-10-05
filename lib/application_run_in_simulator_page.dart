import 'package:flutter/material.dart';

class ApplicationRunInSimulatorPage extends StatefulWidget {
  const ApplicationRunInSimulatorPage({super.key});

  @override
  State<ApplicationRunInSimulatorPage> createState() =>
      _ApplicationRunInSimulatorPageState();
}

class _ApplicationRunInSimulatorPageState
    extends State<ApplicationRunInSimulatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('يرجى تشغيل التطبيق على جهاز حقيقي')),
    );
  }
}
