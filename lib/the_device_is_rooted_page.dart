import 'package:flutter/material.dart';

class TheDeviceIsRootedPage extends StatefulWidget {
  const TheDeviceIsRootedPage({super.key, required this.isRooted});

  final bool isRooted;
  @override
  State<TheDeviceIsRootedPage> createState() => _TheDeviceIsRootedPageState();
}

class _TheDeviceIsRootedPageState extends State<TheDeviceIsRootedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          !widget.isRooted
              ? "لقد تم تفعيل وضع المطور على هذا الجهاز, الرجاء إيقاف تشغيله"
              : 'لقد تم تعديل نسخة نظام التشغيل على هذا الجهاز , يرجى استخدام نسخة غير معدلة',
        ),
      ),
    );
  }
}
