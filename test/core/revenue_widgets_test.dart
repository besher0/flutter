import 'package:coursaty_student_and_teacher/app/widgets/revenue_widgets.dart';
import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('revenue widgets lay out on a phone screen', (tester) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final summary = RevenueSummary.fromJson({
      'totalSubscribers': 3,
      'uniqueSubscribersCount': 2,
      'grossRevenue': 30000,
      'courseDiscount': 1500,
      'codeDiscount': 1000,
      'totalDiscount': 2500,
      'renewals': 1,
      'totalRevenues': 27500,
      'teacherRevenue': 18333.33,
      'platformRevenue': 9166.67,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ListView(
              children: [
                RevenuePeriodSelector(
                  selected: RevenuePeriod.allTime,
                  onChanged: (_) {},
                ),
                RevenueHeroCard(title: 'صافي أرباحك', amount: 18333.33),
                RevenueStatGrid(
                  stats: [
                    RevenueStat(
                      'الاشتراكات',
                      '3',
                      Icons.people,
                      hint: '2 جديد',
                    ),
                    RevenueStat('المبيعات', formatMoney(27500), Icons.payments),
                    RevenueStat('الطلاب', '2', Icons.groups),
                  ],
                ),
                RevenueSection(
                  title: 'كيف حُسبت أرباحك',
                  child: RevenueBreakdown(summary: summary),
                ),
                RevenueMonthlyBars(
                  months: [
                    RevenueMonth.fromJson({
                      'year': 2026,
                      'month': 8,
                      'subscriptions': 1,
                      'teacherRevenue': 6000,
                    }),
                    RevenueMonth.fromJson({
                      'year': 2026,
                      'month': 9,
                      'subscriptions': 2,
                      'teacherRevenue': 12333.33,
                    }),
                  ],
                  valueOf: (month) => month.teacherRevenue,
                ),
                RevenueEmptyPeriod(period: RevenuePeriod.thisMonth()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('18,333.33 ل.س'), findsWidgets);
    expect(find.text('أيلول 2026'), findsOneWidget);
    expect(find.text('− 1,500 ل.س'), findsOneWidget);
  });
}
