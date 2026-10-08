  import 'package:flutter_test/flutter_test.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart'
    as course_models;
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart'
    as lecture_models;
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/lecture_file_access.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_state.dart';

void main() {
  test(
    'first secure video download is grouped under its course and lecture',
    () {
      final course = course_models.CourseDetailsModel(
        course: course_models.Course(id: 'course-1', name: 'Course'),
        lectures: [course_models.Lecture(id: 'lecture-1', title: 'Lecture')],
      );
      final lecture = lecture_models.LectureDetailsModel(
        lecture: lecture_models.Lecture(id: 'lecture-1', title: 'Lecture'),
        videos: [lecture_models.Video(id: 'video-1', videoName: 'Video')],
      );

      final state = MyDownloadsState().withDownloadedFile(
        fileUrl: 'video-1',
        localFilePath: 'secure-hls://video-1',
        courseId: 'course-1',
        lectureId: 'lecture-1',
        courseDetailsModel: course,
        lectureDetailsModel: lecture,
      );

      expect(state.courseIdToCourseDetailsReferences['course-1'], same(course));
      expect(
        state.lectureIdToLectureDetailsReferences['lecture-1'],
        same(lecture),
      );
      expect(state.urlToFileReferences['video-1'], 'secure-hls://video-1');
    },
  );

  test('guest can open a free file through the network viewer', () {
    final file = lecture_models.FileElement(
      fileUrl: 'https://example.test/free.pdf',
      isFree: true,
      locked: false,
    );

    expect(
      canOpenLectureFileAsGuest(file: file, isCourseFree: false, isGuest: true),
      isTrue,
    );
    expect(
      isLectureFileLocked(
        file: file,
        courseId: 'course-1',
        isCourseFree: false,
        isGuest: true,
        activeCourseIds: const [],
      ),
      isFalse,
    );
  });

  test('guest remains locked out of paid files', () {
    final file = lecture_models.FileElement(
      fileUrl: null,
      isFree: false,
      locked: true,
    );

    expect(
      canOpenLectureFileAsGuest(file: file, isCourseFree: false, isGuest: true),
      isFalse,
    );
    expect(
      isLectureFileLocked(
        file: file,
        courseId: 'course-1',
        isCourseFree: false,
        isGuest: true,
        activeCourseIds: const [],
      ),
      isTrue,
    );
  });

  test('subscribed users retain access to paid files', () {
    final file = lecture_models.FileElement(
      fileUrl: 'https://example.test/paid.pdf',
      isFree: false,
      locked: false,
    );

    expect(
      isLectureFileLocked(
        file: file,
        courseId: 'course-1',
        isCourseFree: false,
        isGuest: false,
        activeCourseIds: const ['course-1'],
      ),
      isFalse,
    );
  });
}
