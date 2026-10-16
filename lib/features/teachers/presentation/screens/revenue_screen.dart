import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/revenue_widgets.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/model/teacher_revenue_model.dart';

class TeacherRevenueScreen extends StatefulWidget {
  const TeacherRevenueScreen({super.key});

  @override
  State<TeacherRevenueScreen> createState() => _TeacherRevenueScreenState();
}

class _TeacherRevenueScreenState extends State<TeacherRevenueScreen> {
  RevenuePeriod _period = RevenuePeriod.allTime;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    BlocProvider.of<TeachersBloc>(
      context,
    ).add(GetRevenuesEvent(period: _period));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "إيراداتي"),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: RevenuePeriodSelector(
                selected: _period,
                onChanged: (period) {
                  setState(() => _period = period);
                  _load();
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<TeachersBloc, TeachersState>(
                buildWhen: (p, c) => p.getRevenues != c.getRevenues,
                builder: (context, state) {
                  if (state.getRevenues.isLoading) {
                    return Center(child: CoursatyAppLoader());
                  }
                  final model = state.teacherRevenueModel;
                  if (state.getRevenues.isFailed || model == null) {
                    return Center(child: TryAgainWidget(onPress: _load));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _load(),
                    child: _RevenueReport(model: model, period: _period),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueReport extends StatelessWidget {
  const _RevenueReport({required this.model, required this.period});

  final TeacherRevenueModel model;
  final RevenuePeriod period;

  @override
  Widget build(BuildContext context) {
    final summary = model.invoice.summary;
    final hasSales = summary.subscriptions > 0;
    final courses = _courseRows();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        RevenueHeroCard(
          title: 'صافي أرباحك · ${period.label}',
          amount: summary.teacherRevenue,
          footer: [
            Text('من مبيعات ${formatMoney(summary.totalRevenues)}'),
            Text('${formatCount(summary.subscriptions)} اشتراك'),
          ],
        ),
        const SizedBox(height: 12),
        _BalanceCard(balance: model.withdrawals),
        const SizedBox(height: 12),
        if (!hasSales)
          RevenueSection(
            title: 'ملخص الفترة',
            child: RevenueEmptyPeriod(period: period),
          )
        else ...[
          RevenueStatGrid(
            stats: [
              RevenueStat(
                'إجمالي المبيعات',
                formatMoney(summary.totalRevenues),
                Icons.payments_outlined,
                hint: 'ما دفعه الطلاب بعد الخصومات',
              ),
              RevenueStat(
                'الاشتراكات',
                formatCount(summary.subscriptions),
                Icons.how_to_reg_outlined,
                hint:
                    '${formatCount(summary.initialSubscriptions)} جديد · ${formatCount(summary.renewals)} تجديد',
              ),
              RevenueStat(
                'الطلاب',
                formatCount(summary.uniqueStudents),
                Icons.groups_outlined,
                hint: 'طلاب مختلفون',
              ),
              RevenueStat(
                'متوسط الاشتراك',
                formatMoney(summary.averagePerSubscription),
                Icons.trending_up,
                hint: 'المدفوع لكل اشتراك',
              ),
              RevenueStat(
                'الخصومات الممنوحة',
                formatMoney(summary.totalDiscount),
                Icons.local_offer_outlined,
                hint:
                    'كورس ${formatMoney(summary.courseDiscount)} · أكواد ${formatMoney(summary.codeDiscount)}',
              ),
              RevenueStat(
                'حصة المنصة',
                formatMoney(summary.platformRevenue),
                Icons.account_balance_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          RevenueSection(
            title: 'كيف حُسبت أرباحك',
            child: RevenueBreakdown(summary: summary),
          ),
          if (model.invoice.monthly.length > 1) ...[
            const SizedBox(height: 12),
            RevenueSection(
              title: 'أرباحك حسب الشهر',
              subtitle: 'آخر ستة أشهر فيها اشتراكات',
              child: RevenueMonthlyBars(
                months: model.invoice.monthly,
                valueOf: (month) => month.teacherRevenue,
              ),
            ),
          ],
        ],
        if (courses.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'الكورسات (${formatCount(courses.length)})',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            'مرتبة حسب أرباحك في الفترة المختارة',
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.greyDark),
          ),
          const SizedBox(height: 8),
          for (final row in courses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CourseRevenueCard(
                row: row,
                totalTeacherRevenue: summary.teacherRevenue,
              ),
            ),
        ],
      ],
    );
  }

  /// Courses paired with their invoice by id, most profitable first.
  List<_CourseRow> _courseRows() {
    final rows = <_CourseRow>[];
    final seen = <String?>{};
    for (final course in model.courses) {
      seen.add(course.id);
      rows.add(_CourseRow(course, model.invoice.courseById(course.id)));
    }
    // Courses sold in the period but no longer listed for the teacher.
    for (final invoice in model.invoice.courses) {
      if (!seen.contains(invoice.id)) rows.add(_CourseRow(null, invoice));
    }
    rows.sort(
      (a, b) => b.teacherRevenue.compareTo(a.teacherRevenue) != 0
          ? b.teacherRevenue.compareTo(a.teacherRevenue)
          : b.subscriptions.compareTo(a.subscriptions),
    );
    return rows;
  }
}

class _CourseRow {
  _CourseRow(this.course, this.invoice);

  final TeacherCourseRevenue? course;
  final RevenueCourseInvoice? invoice;

  String get name => course?.name ?? invoice?.name ?? '-';
  double get teacherRevenue => invoice?.summary.teacherRevenue ?? 0;
  int get subscriptions => invoice?.summary.subscriptions ?? 0;
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final TeacherBalance balance;

  @override
  Widget build(BuildContext context) {
    return RevenueSection(
      title: 'رصيدك',
      subtitle: 'محسوب على كامل الفترات',
      child: Row(
        children: [
          Expanded(
            child: _BalanceFigure(
              label: 'المتاح للسحب',
              value: formatMoney(balance.remainingAmount),
              color: AppColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: context.colorScheme.primary.withValues(alpha: 0.15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BalanceFigure(
              label: 'تم سحبه (${formatCount(balance.withdrawalCount)} عملية)',
              value: formatMoney(balance.withdrawnAmount),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceFigure extends StatelessWidget {
  const _BalanceFigure({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.greyDark),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseRevenueCard extends StatelessWidget {
  const _CourseRevenueCard({
    required this.row,
    required this.totalTeacherRevenue,
  });

  final _CourseRow row;
  final double totalTeacherRevenue;

  @override
  Widget build(BuildContext context) {
    final course = row.course;
    final invoice = row.invoice;
    final summary = invoice?.summary;
    final primary = context.colorScheme.primary;
    final share = totalTeacherRevenue == 0
        ? 0.0
        : row.teacherRevenue / totalTeacherRevenue;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            row.name,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  '${formatCount(row.subscriptions)} اشتراك',
                  if (course != null && course.ratersCount > 0)
                    '★ ${course.ratingAverage.toStringAsFixed(1)} (${formatCount(course.ratersCount)})',
                ].join(' · '),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: share,
                        minHeight: 6,
                        color: primary,
                        backgroundColor: primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatMoney(row.teacherRevenue),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            if (summary != null && summary.subscriptions > 0) ...[
              RevenueRow('المبيعات', formatMoney(summary.totalRevenues)),
              RevenueRow(
                'حصتك (${formatPercent(summary.teacherShare)})',
                formatMoney(summary.teacherRevenue),
                emphasized: true,
              ),
              RevenueRow('حصة المنصة', formatMoney(summary.platformRevenue)),
              RevenueRow(
                'الاشتراكات',
                '${formatCount(summary.initialSubscriptions)} جديد · ${formatCount(summary.renewals)} تجديد',
              ),
              if (summary.totalDiscount > 0)
                RevenueRow(
                  'الخصومات الممنوحة',
                  formatMoney(summary.totalDiscount),
                ),
            ] else
              RevenueRow('المبيعات', 'لا اشتراكات في هذه الفترة'),
            if (course != null) ...[
              const Divider(height: 20),
              RevenueRow('السعر الحالي', formatMoney(course.price)),
              RevenueRow(
                'نسبتك الحالية',
                formatPercent(course.teacherPercentage),
              ),
              RevenueRow('تاريخ النشر', _formatDate(course.publishedAt)),
              if (course.expiresAt != null)
                RevenueRow('تاريخ الانتهاء', _formatDate(course.expiresAt)),
              RevenueRow(
                'الحالة',
                course.isCompleted ? 'مكتمل' : 'قيد الإنجاز',
              ),
            ],
            if (invoice != null && invoice.lineItems.isNotEmpty) ...[
              const Divider(height: 20),
              Text(
                'الاشتراكات حسب السعر',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              RevenueLineItemsList(lineItems: invoice.lineItems),
            ],
            if (invoice != null && invoice.codeGroups.isNotEmpty) ...[
              const Divider(height: 20),
              Text(
                'مصادر الاشتراك',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              RevenueCodeGroupsList(codeGroups: invoice.codeGroups),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) =>
    date == null ? '-' : DateFormat('yyyy/MM/dd').format(date.toLocal());
