import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/course_link_tile.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/widgets/payment_video_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _host(Widget child) => MaterialApp(
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(body: child),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PaymentVideoLink', () {
    for (final url in <String?>[null, '', '   ']) {
      testWidgets(
        'shows nothing when the video URL is ${url == null ? 'null' : 'blank'}',
        (tester) async {
          await tester.pumpWidget(_host(PaymentVideoLink(url: url)));

          expect(find.text(PaymentVideoLink.label), findsNothing);
          expect(find.byType(CourseLinkTile), findsNothing);
          expect(find.byType(SvgPicture), findsNothing);
        },
      );
    }

    testWidgets('shows the Telegram link and opens it from the icon or text', (
      tester,
    ) async {
      final opened = <String>[];
      await tester.pumpWidget(
        _host(
          PaymentVideoLink(
            url: ' https://t.me/coursaty/123 ',
            onOpen: (url) async => opened.add(url),
          ),
        ),
      );

      expect(find.text('فيديو توضيحي لعملية الدفع والاشتراك'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);

      await tester.tap(find.text(PaymentVideoLink.label));
      await tester.tap(find.byType(SvgPicture));

      expect(opened, [
        'https://t.me/coursaty/123',
        'https://t.me/coursaty/123',
      ]);
    });
  });

  group('CoursePaymentInfo.paymentVideoUrl', () {
    test('is null when the backend sends null', () {
      final info = CoursePaymentInfo.fromJson({
        'course': {'id': 'c1', 'name': 'x', 'paymentVideoUrl': null},
      });
      expect(info.paymentVideoUrl, isNull);
      expect(info.hasPaymentVideo, isFalse);
    });

    test('is read from the course-details payload when set', () {
      final info = CoursePaymentInfo.fromJson({
        'course': {
          'id': 'c1',
          'name': 'x',
          'paymentVideoUrl': 'https://t.me/coursaty/123',
        },
      });
      expect(info.paymentVideoUrl, 'https://t.me/coursaty/123');
      expect(info.hasPaymentVideo, isTrue);
    });
  });
}
