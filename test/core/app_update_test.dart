import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('admin-controlled app update', () {
    final info = AppUpdateInfo.fromJson({
      'updateAvailable': true,
      'required': true,
      'latestVersion': '2.1.1',
      'latestBuild': 7,
      'storeUrl': 'https://play.google.com/store/apps/details?id=com.YamanKartal.coursaty_app',
      'downloadUrl': 'https://example.com/coursaty.apk',
      'message': '  ',
    });

    test('reads the server verdict', () {
      expect(info.required, isTrue);
      expect(info.latestBuild, 7);
      expect(info.message, isNull);
    });

    test('store installs update from the store, others from the direct link', () {
      expect(
        AppUpdateService.updateUri(info, installerStore: 'com.android.vending')?.host,
        'play.google.com',
      );
      expect(AppUpdateService.updateUri(info, installerStore: null)?.host, 'example.com');
      expect(
        AppUpdateService.updateUri(info, installerStore: 'com.google.android.packageinstaller')
            ?.host,
        'example.com',
      );
      expect(AppUpdateService.updateUri(info, isIOS: true)?.host, 'play.google.com');
    });

    test('falls back to whichever link exists', () {
      const storeOnly = AppUpdateInfo(
        updateAvailable: true,
        required: false,
        storeUrl: 'https://play.google.com/x',
      );
      expect(AppUpdateService.updateUri(storeOnly)?.host, 'play.google.com');
      const none = AppUpdateInfo(updateAvailable: true, required: true);
      expect(AppUpdateService.updateUri(none), isNull);
    });
  });

  // Students' downloads are re-made only when the server's contentVersion
  // changes, which happens only when a new videoUrl is sent.
  test('editing video details never sends a video URL', () {
    final data = UpsertVideoParams(
      lectureId: 'lecture-1',
      videoId: 'video-1',
      videoName: 'اسم جديد',
      description: 'وصف',
      isFree: true,
      sortOrder: '2',
    ).data();
    expect(data.containsKey('videoUrl'), isFalse);
    expect(data['videoName'], 'اسم جديد');
  });
}
