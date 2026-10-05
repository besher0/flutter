import 'package:coursaty_student_and_teacher/core/security/screen_capture_policy.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

export 'screen_capture_policy.dart' show ScreenCaptureLease;

/// Protects actual learning material for students and guests only. Teacher
/// authoring and preview screens intentionally remain capturable.
class SecureStudentContent extends StatefulWidget {
  const SecureStudentContent({super.key, required this.child});

  final Widget child;

  @override
  State<SecureStudentContent> createState() => _SecureStudentContentState();
}

abstract final class StudentContentProtection {
  StudentContentProtection._();

  static ScreenCaptureLease? claim() {
    final prefs = GetIt.I<PrefsRepository>();
    return prefs.isStudent || prefs.isGuest
        ? ScreenCapturePolicy.instance.protectEducationalContent()
        : null;
  }
}

class _SecureStudentContentState extends State<SecureStudentContent> {
  ScreenCaptureLease? _lease;

  @override
  void initState() {
    super.initState();
    _lease = StudentContentProtection.claim();
  }

  @override
  void dispose() {
    _lease?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
