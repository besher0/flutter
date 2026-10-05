import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses a pending interest and preserves its course and request state',
    () {
      final interest = CourseInterest.fromJson({
        'id': 'interest-1',
        'courseId': 'course-1',
        'source': 'QR_SCREENSHOT',
        'course': {
          'id': 'course-1',
          'name': 'البرمجة',
          'basePrice': 100,
          'paymentQrUrl': 'https://example.test/qr.webp',
        },
        'pendingRequest': {'id': 'request-1', 'status': 'PENDING'},
      });

      expect(interest.source, InterestSource.qrScreenshot);
      expect(interest.course.finalPrice, 100);
      expect(interest.pendingRequest?.isPending, isTrue);
      expect(interest.isAwaitingReceipt, isFalse);
    },
  );

  test('reads the course-details payment contract and expiry state', () {
    final info = CoursePaymentInfo.fromJson({
      'course': {
        'id': 'course-2',
        'name': 'دورات برمجة 3',
        'basePrice': 700,
        'discountedPrice': 630,
        'isFree': false,
        'paymentQrUrl': 'https://example.test/qr.jpg',
      },
      'details': {'expiresAt': '2099-09-28T00:00:00.000Z', 'isExpired': false},
    });

    expect(info.finalPrice, 630);
    expect(info.isFree, isFalse);
    expect(info.isExpiredNow, isFalse);
    expect(info.canStartReceiptFlow, isTrue);
  });

  test('blocks receipt flow for expired and zero-price courses', () {
    final expired = CoursePaymentInfo.fromJson({
      'course': {
        'id': 'course-3',
        'name': 'منتهي',
        'basePrice': 700,
        'isFree': false,
        'paymentQrUrl': 'https://example.test/qr.jpg',
      },
      'details': {'isExpired': true},
    });
    final zeroPrice = CoursePaymentInfo.fromJson({
      'course': {
        'id': 'course-4',
        'name': 'سعر صفري',
        'basePrice': 0,
        'isFree': false,
        'paymentQrUrl': 'https://example.test/qr.jpg',
      },
    });

    expect(expired.canStartReceiptFlow, isFalse);
    expect(expired.ineligibilityReason, contains('انتهت'));
    expect(zeroPrice.canStartReceiptFlow, isFalse);
    expect(zeroPrice.ineligibilityReason, contains('سعر'));
  });
}
