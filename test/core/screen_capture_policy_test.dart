import 'package:coursaty_student_and_teacher/core/security/screen_capture_policy.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCaptureController implements ScreenCaptureController {
  final List<String> calls = [];

  @override
  Future<void> allowCapture() async => calls.add('allow');

  @override
  Future<void> blockCapture() async => calls.add('block');
}

void main() {
  test(
    'nested learning scopes remain protected until every scope is released',
    () async {
      final controller = _FakeCaptureController();
      final policy = ScreenCapturePolicy(controller: controller);

      final first = policy.protectEducationalContent();
      final second = policy.protectEducationalContent();
      await policy.waitForIdle();
      expect(controller.calls.last, 'block');

      first.release();
      await policy.waitForIdle();
      expect(controller.calls.last, 'block');

      second.release();
      await policy.waitForIdle();
      expect(controller.calls.last, 'allow');
    },
  );

  test('temporary QR allowance restores protection after it closes', () async {
    final controller = _FakeCaptureController();
    final policy = ScreenCapturePolicy(controller: controller);

    final lesson = policy.protectEducationalContent();
    await policy.waitForIdle();
    final qr = policy.temporarilyAllowCapture();
    await policy.waitForIdle();
    expect(controller.calls.last, 'allow');

    qr.release();
    await policy.waitForIdle();
    expect(controller.calls.last, 'block');

    lesson.release();
    await policy.waitForIdle();
    expect(controller.calls.last, 'allow');
  });
}
