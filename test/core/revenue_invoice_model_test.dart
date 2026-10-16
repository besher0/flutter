import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_revenue_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _invoice() => {
  'currency': 'SYP',
  'summary': {
    'totalSubscribers': 3,
    'uniqueSubscribersCount': 2,
    'grossRevenue': 30000,
    'courseDiscount': 1500.5,
    'codeDiscount': 1000,
    'totalDiscount': 2500.5,
    'initialSubscriptions': 2,
    'renewals': 1,
    'totalRevenues': 27499.5,
    'teacherRevenue': 18332.83,
    'platformRevenue': 9166.67,
  },
  'courses': [
    {
      'course': {'id': 'b', 'name': 'Course B'},
      'lineItems': [
        {
          'coursePrice': 10000,
          'subscribersCount': 3,
          'discount': {'percentage': 8.34, 'amountPerSubscriber': 833.5},
          'subtotal': 27499.5,
          'teacherPercentage': 66.67,
          'teacherRevenue': 18332.83,
          'platformRevenue': 9166.67,
        },
      ],
      'codeGroups': [
        {
          'codeGroupId': null,
          'batchName': null,
          'discountPercentage': 0,
          'subscriptionsCount': 1,
          'discountAmount': 0,
          'revenue': 9500,
        },
      ],
      'summary': {'totalSubscribers': 3, 'teacherRevenue': 18332.83},
    },
    {
      'course': {'id': 'a', 'name': 'Course A'},
      'lineItems': [],
      'codeGroups': [],
      'summary': {'totalSubscribers': 0},
    },
  ],
  'monthly': [
    {
      'year': 2026,
      'month': 9,
      'subscriptions': 3,
      'totalRevenues': 27499.5,
      'teacherRevenue': 18332.83,
      'platformRevenue': 9166.67,
    },
  ],
};

void main() {
  test('reads decimal amounts and percentages without failing', () {
    final invoice = RevenueInvoice.fromJson(_invoice());

    expect(invoice.summary.teacherRevenue, 18332.83);
    expect(invoice.summary.renewals, 1);
    expect(invoice.summary.averagePerSubscription, closeTo(9166.5, 0.01));
    expect(invoice.courses.first.lineItems.single.teacherPercentage, 66.67);
    expect(invoice.courses.first.lineItems.single.paidPerSubscription, 9166.5);
    expect(
      invoice.courses.first.codeGroups.single.displayName,
      'بدون كود (إيصالات دفع)',
    );
    expect(invoice.monthly.single.month, 9);
  });

  test('rebuilds missing fields sent by older servers', () {
    final summary = RevenueSummary.fromJson({
      'totalSubscribers': 4,
      'renewals': 1,
      'totalDiscount': 500,
      'totalRevenues': 9500,
    });

    expect(summary.grossRevenue, 10000);
    expect(summary.initialSubscriptions, 3);
    expect(RevenueInvoice.fromJson(const {}).monthly, isEmpty);
  });

  test('teacher courses are matched to their invoice by id, not position', () {
    final model = TeacherRevenueModel.fromJson({
      'courses': [
        {
          'course': {'id': 'a', 'name': 'Course A', 'price': 5000},
          'revenue': {'teacherPercentage': 66.67},
          'rating': {'average': 4.5, 'ratersCount': 2},
        },
        {
          'course': {'id': 'b', 'name': 'Course B', 'price': 10000},
        },
      ],
      'withdrawals': {'withdrawnAmount': 1000.5, 'remainingAmount': 17332.33},
      'invoice': _invoice(),
    });

    expect(model.invoice.courseById('a')!.name, 'Course A');
    expect(
      model.invoice.courseById(model.courses[1].id)!.summary.subscriptions,
      3,
    );
    expect(model.courses.first.teacherPercentage, 66.67);
    expect(model.withdrawals.remainingAmount, 17332.33);
  });

  test('course statistics keep decimal percentages', () {
    final stats = CourseStatisticsModel.fromJson({
      'course': {'publishedAt': '2026-01-02T00:00:00.000Z'},
      'subscriptionPrice': {
        'beforeDiscount': 10000,
        'discountPercentage': 12.5,
        'afterDiscount': 8750,
      },
      'rating': {'average': 4.25, 'ratersCount': 8},
      'percentages': {'myPercentage': 66.67},
      'invoice': _invoice(),
    });

    expect(stats.myPercentage, 66.67);
    expect(stats.discountPercentage, 12.5);
    expect(stats.isPriceVisible, isTrue);
    expect(stats.courseInvoice!.id, 'b');
  });

  test('period query sends year and month only when chosen', () {
    final now = DateTime(2026, 1, 15);
    expect(RevenuePeriod.allTime.toQuery(), isEmpty);
    expect(RevenuePeriod.lastMonth(now).toQuery(), {'year': 2025, 'month': 12});
    expect(RevenuePeriod.thisYear(now).toQuery(), {'year': 2026});
  });
}
