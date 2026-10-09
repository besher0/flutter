import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/teacher_course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shape of `GET courses/:id/details` (see backend CourseService.getCourseDetails).
Map<String, dynamic> studentDetailsJson({bool? isPriceVisible}) => {
  'course': {
    'id': 'course-1',
    'name': 'Course',
    'basePrice': 400,
    'discountedPrice': 300,
    'isFree': false,
    'paymentQrUrl': 'https://cdn.example/qr.webp',
    'isPriceVisible': ?isPriceVisible,
  },
  'details': {
    'description': 'About',
    'telegramUrl': 'https://t.me/course_group',
    'discussionGroupUrl': 'https://t.me/discussion',
  },
  'lectures': [],
};

void main() {
  group('student course details', () {
    test('reads a hidden price flag', () {
      final model = CourseDetailsModel.fromJson(
        studentDetailsJson(isPriceVisible: false),
      );
      expect(model.course!.isPriceVisible, isFalse);
      // Prices are still parsed: the subscription flow needs them.
      expect(model.course!.discountedPrice, 300);
    });

    test('treats a missing flag (older backend, cached download) as visible', () {
      final model = CourseDetailsModel.fromJson(studentDetailsJson());
      expect(model.course!.isPriceVisible, isTrue);
    });

    test('reads the course Telegram link from details, where the backend sends it', () {
      final model = CourseDetailsModel.fromJson(studentDetailsJson());
      expect(model.details!.telegramUrl, 'https://t.me/course_group');
      expect(model.course!.telegramUrl, isNull);
    });

    test('keeps the flag and Telegram link across offline caching', () {
      final cached = CourseDetailsModel.fromJson(
        CourseDetailsModel.fromJson(
          studentDetailsJson(isPriceVisible: false),
        ).toJson(),
      );
      expect(cached.course!.isPriceVisible, isFalse);
      expect(cached.details!.telegramUrl, 'https://t.me/course_group');
    });
  });

  group('teacher course details (edit form source)', () {
    Map<String, dynamic> json({bool? isPriceVisible}) => {
      'course': {
        'id': 'course-1',
        'name': 'Course',
        'basePrice': 400,
        'discountedPrice': 300,
        'isPriceVisible': ?isPriceVisible,
      },
      'details': {'telegramUrl': 'https://t.me/course_group'},
      'lectures': [],
    };

    test('pre-fills the visibility and the Telegram link', () {
      final model = TeacherCourseDetailsResponseModel.fromJson(
        json(isPriceVisible: false),
      );
      expect(model.course!.isPriceVisible, isFalse);
      expect(model.details!.telegramUrl, 'https://t.me/course_group');
    });

    test('defaults to visible', () {
      expect(
        TeacherCourseDetailsResponseModel.fromJson(json()).course!.isPriceVisible,
        isTrue,
      );
    });
  });

  group('create / edit request', () {
    UpsertCourseParams params({
      required int price,
      required int discountedPrice,
      bool isPriceVisible = true,
      String? courseId,
      String? telegramUrl,
    }) => UpsertCourseParams(
      name: 'Course',
      description: 'About',
      subjectId: 'subject-1',
      categoryId: 'category-1',
      price: price,
      discountedPrice: discountedPrice,
      isFree: false,
      isPriceVisible: isPriceVisible,
      courseId: courseId,
      telegramUrl: telegramUrl,
    );

    test('sends the final price after discount, never a percentage', () {
      final body = params(price: 400, discountedPrice: 300).map;

      expect(body['price'], 400);
      expect(body['discountedPrice'], 300);
      // The backend reads `courseDiscountPercentage` as a final price too;
      // sending a percentage there produced near-free courses.
      expect(body.containsKey('courseDiscountPercentage'), isFalse);
    });

    test('a course without discount sends its full price as the final price', () {
      final body = params(price: 400, discountedPrice: 400).map;
      expect(body['discountedPrice'], 400);
    });

    test('sends the price visibility on create and on edit', () {
      expect(
        params(price: 1, discountedPrice: 1, isPriceVisible: false).map['isPriceVisible'],
        isFalse,
      );
      expect(
        params(price: 1, discountedPrice: 1, courseId: 'course-1').map['isPriceVisible'],
        isTrue,
      );
    });

    test('an edit always carries the Telegram link so it is kept or cleared on purpose', () {
      expect(
        params(price: 1, discountedPrice: 1, courseId: 'c', telegramUrl: 'https://t.me/x')
            .map['telegramUrl'],
        'https://t.me/x',
      );
      final cleared = params(price: 1, discountedPrice: 1, courseId: 'c').map;
      expect(cleared.containsKey('telegramUrl'), isTrue);
      expect(cleared['telegramUrl'], isNull);
    });
  });

  test('payment info reads the flag but keeps the amount for the payment flow', () {
    final info = CoursePaymentInfo.fromJson(studentDetailsJson(isPriceVisible: false));
    expect(info.isPriceVisible, isFalse);
    expect(info.finalPrice, 300);
    expect(CoursePaymentInfo.fromJson(studentDetailsJson()).isPriceVisible, isTrue);
  });

  test('teacher statistics read the flag', () {
    final hidden = SubscriptionPrice.fromJson({
      'beforeDiscount': 400,
      'afterDiscount': 300,
      'isPriceVisible': false,
    });
    expect(hidden.isPriceVisible, isFalse);
    expect(SubscriptionPrice.fromJson({'afterDiscount': 300}).isPriceVisible, isTrue);
  });
}
