import 'package:coursaty_student_and_teacher/core/common/constant/configuration/paid_content_policy.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/lecture_file_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only an iPhone whose admin hides paid content hides it', () {
    expect(PaidContentPolicy.isHidden(isIOS: true, iosVisible: false), isTrue);
    expect(PaidContentPolicy.isHidden(isIOS: true, iosVisible: true), isFalse);
    expect(PaidContentPolicy.isHidden(isIOS: false, iosVisible: false), isFalse);
  });

  test('Android tests never hide paid content', () {
    PaidContentPolicy.iosVisibleForTesting = false;
    expect(PaidContentPolicy.hidePaid, isFalse);
  });

  group('locked videos (hidden when paid content is hidden)', () {
    bool locked(Video video, {bool guest = false, List<String> active = const []}) =>
        isLectureVideoLocked(
          video: video,
          courseId: 'c1',
          isCourseFree: false,
          isGuest: guest,
          activeCourseIds: active,
        );

    test('a paid video is locked until the course is owned', () {
      final video = Video(id: 'v1', isFree: false);
      expect(locked(video), isTrue);
      expect(locked(video, active: ['c1']), isFalse);
    });

    test('a free video stays visible, also to guests', () {
      final video = Video(id: 'v1', isFree: true);
      expect(locked(video), isFalse);
      expect(locked(video, guest: true), isFalse);
    });

    test('the server lock always wins', () {
      expect(locked(Video(id: 'v1', isFree: true, locked: true), active: ['c1']), isTrue);
    });
  });
}
