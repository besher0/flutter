import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
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
    final diagnostics = DeviceInfoService.emulatorDiagnostics;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يرجى تشغيل التطبيق على جهاز حقيقي',
                textAlign: TextAlign.center,
              ),
              // A code the user can send to support when a real device is
              // refused by mistake.
              if (diagnostics.isNotEmpty) ...[
                const SizedBox(height: 12),
                SelectableText(
                  'رمز التشخيص: $diagnostics',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
