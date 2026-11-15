import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

UpsertCourseParams params({String? courseId, String? introVideoUrl}) =>
    UpsertCourseParams(
      name: 'كورس',
      description: 'وصف',
      subjectId: 's1',
      categoryId: 'c1',
      price: 50000,
      discountedPrice: 40000,
      isFree: false,
      expiresAt: DateTime.utc(2027, 1, 1),
      introVideoUrl: introVideoUrl,
      telegramUrl: 'https://t.me/g',
      discussionGroupUrl: 'https://t.me/g',
      courseId: courseId,
    );

void main() {
  test('a new course sends its subject, price and expiry', () {
    final map = params().map;
    expect(map['subjectId'], 's1');
    expect(map['price'], 50000);
    expect(map['discountedPrice'], 40000);
    expect(map['isFree'], isFalse);
    expect(map.containsKey('expiresAt'), isTrue);
  });

  test('an edit sends only the course details the teacher may change', () {
    final map = params(courseId: 'id-1').map;
    expect(map.keys.toSet(), {
      'name',
      'description',
      'categoryId',
      'isPriceVisible',
      'introVideoUrl',
      'telegramUrl',
      'discussionGroupUrl',
    });
    // An emptied intro video is cleared on the server.
    expect(map['introVideoUrl'], isNull);
    expect(
      params(courseId: 'id-1', introVideoUrl: 'https://y.tu/x').map,
      containsPair('introVideoUrl', 'https://y.tu/x'),
    );
  });
}
