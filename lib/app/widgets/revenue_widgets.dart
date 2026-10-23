import 'dart:math' as math;

import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final _moneyFormat = NumberFormat('#,##0.##', 'en');
final _countFormat = NumberFormat('#,##0', 'en');

/// "12,600 ل.س"
String formatMoney(double value) => '${_moneyFormat.format(value)} ل.س';

String formatCount(int value) => _countFormat.format(value);

String formatPercent(double value) => '${_moneyFormat.format(value)}%';

const _arabicMonths = [
  'كانون الثاني',
  'شباط',
  'آذار',
  'نيسان',
  'أيار',
  'حزيران',
  'تموز',
  'آب',
  'أيلول',
  'تشرين الأول',
  'تشرين الثاني',
  'كانون الأول',
];

String arabicMonth(int month, int year) =>
    '${_arabicMonths[(month - 1).clamp(0, 11)]} $year';

/// Horizontal chips to pick the report period.
class RevenuePeriodSelector extends StatelessWidget {
  const RevenuePeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final RevenuePeriod selected;
  final ValueChanged<RevenuePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = RevenuePeriod.options();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(
                  option.label,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                selected: option == selected,
                onSelected: (_) {
                  if (option != selected) onChanged(option);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The headline figure of a report.
class RevenueHeroCard extends StatelessWidget {
  const RevenueHeroCard({
    super.key,
    required this.title,
    required this.amount,
    this.footer = const [],
  });

  final String title;
  final double amount;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [primary, Color.lerp(primary, Colors.black, 0.35)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              formatMoney(amount),
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 12),
            DefaultTextStyle.merge(
              style: GoogleFonts.cairo(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
              child: Wrap(spacing: 16, runSpacing: 6, children: footer),
            ),
          ],
        ],
      ),
    );
  }
}

class RevenueStat {
  const RevenueStat(this.label, this.value, this.icon, {this.hint});

  final String label;
  final String value;
  final IconData icon;

  /// A smaller second line, e.g. a split or a comparison.
  final String? hint;
}

/// Two-column grid of key figures.
class RevenueStatGrid extends StatelessWidget {
  const RevenueStatGrid({super.key, required this.stats});

  final List<RevenueStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stat in stats)
              SizedBox(
                width: width,
                child: _StatTile(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final RevenueStat stat;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 18, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              stat.value,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          if (stat.hint != null)
            Text(
              stat.hint!,
              maxLines: 2,
              style: GoogleFonts.cairo(fontSize: 12, color: AppColors.greyDark),
            ),
        ],
      ),
    );
  }
}

/// A titled card that groups one part of a report.
class RevenueSection extends StatelessWidget {
  const RevenueSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: GoogleFonts.cairo(fontSize: 12, color: AppColors.greyDark),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// One "label ...... value" row.
class RevenueRow extends StatelessWidget {
  const RevenueRow(
    this.label,
    this.value, {
    super.key,
    this.emphasized = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final weight = emphasized ? FontWeight.w800 : FontWeight.w600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: weight,
                color: emphasized ? null : AppColors.greyDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: weight,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// From list prices to what was paid, then who receives it.
class RevenueBreakdown extends StatelessWidget {
  const RevenueBreakdown({
    super.key,
    required this.summary,
    this.highlightTeacher = true,
  });

  final RevenueSummary summary;

  /// Teacher view ("حصتك") versus admin view ("حصة الأستاذ").
  final bool highlightTeacher;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    final teacherShare = summary.teacherShare;
    return Column(
      children: [
        RevenueRow(
          'قيمة الاشتراكات بالسعر الأساسي',
          formatMoney(summary.grossRevenue),
        ),
        if (summary.courseDiscount > 0)
          RevenueRow(
            'خصم الكورس',
            '− ${formatMoney(summary.courseDiscount)}',
            valueColor: AppColors.danger,
          ),
        if (summary.codeDiscount > 0)
          RevenueRow(
            'خصم الأكواد',
            '− ${formatMoney(summary.codeDiscount)}',
            valueColor: AppColors.danger,
          ),
        const Divider(),
        RevenueRow(
          'المبلغ المدفوع فعلياً',
          formatMoney(summary.totalRevenues),
          emphasized: true,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(
                  flex: math.max(1, (teacherShare * 10).round()),
                  child: ColoredBox(color: primary),
                ),
                Expanded(
                  flex: math.max(1, ((100 - teacherShare) * 10).round()),
                  child: const ColoredBox(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _LegendRow(
          color: primary,
          label: highlightTeacher ? 'حصتك' : 'حصة الأستاذ',
          value:
              '${formatMoney(summary.teacherRevenue)} (${formatPercent(teacherShare)})',
        ),
        _LegendRow(
          color: AppColors.secondary,
          label: 'حصة المنصة',
          value:
              '${formatMoney(summary.platformRevenue)} (${formatPercent(summary.totalRevenues == 0 ? 0 : 100 - teacherShare)})',
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Last months as horizontal bars, newest first.
class RevenueMonthlyBars extends StatelessWidget {
  const RevenueMonthlyBars({
    super.key,
    required this.months,
    required this.valueOf,
    this.maxMonths = 6,
  });

  final List<RevenueMonth> months;
  final double Function(RevenueMonth month) valueOf;
  final int maxMonths;

  @override
  Widget build(BuildContext context) {
    final recent = months.reversed.take(maxMonths).toList();
    final maxValue = recent.fold<double>(
      0,
      (max, month) => math.max(max, valueOf(month)),
    );
    final primary = context.colorScheme.primary;
    return Column(
      children: [
        for (final month in recent)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        arabicMonth(month.month, month.year),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '${formatMoney(valueOf(month))} · ${formatCount(month.subscriptions)} اشتراك',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: maxValue == 0 ? 0 : valueOf(month) / maxValue,
                    minHeight: 8,
                    color: primary,
                    backgroundColor: primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Subscriptions grouped by the price actually paid.
class RevenueLineItemsList extends StatelessWidget {
  const RevenueLineItemsList({super.key, required this.lineItems});

  final List<RevenueLineItem> lineItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final line in lineItems)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatCount(line.subscriptions)} اشتراك × ${formatMoney(line.paidPerSubscription)}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  line.discountPercentage > 0
                      ? 'السعر الأساسي ${formatMoney(line.coursePrice)} · خصم ${formatPercent(line.discountPercentage)}'
                      : 'السعر الأساسي ${formatMoney(line.coursePrice)} · بدون خصم',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 4),
                RevenueRow('الإجمالي', formatMoney(line.subtotal)),
                RevenueRow(
                  'حصة الأستاذ (${formatPercent(line.teacherPercentage)})',
                  formatMoney(line.teacherRevenue),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Sales per code batch.
class RevenueCodeGroupsList extends StatelessWidget {
  const RevenueCodeGroupsList({super.key, required this.codeGroups});

  final List<RevenueCodeGroup> codeGroups;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final group in codeGroups)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  group.codeGroupId == null
                      ? Icons.receipt_long_outlined
                      : Icons.confirmation_number_outlined,
                  size: 18,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        group.discountPercentage > 0
                            ? '${formatCount(group.subscriptions)} اشتراك · خصم ${formatPercent(group.discountPercentage)}'
                            : '${formatCount(group.subscriptions)} اشتراك',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMoney(group.revenue),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Shown when the chosen period has no sales.
class RevenueEmptyPeriod extends StatelessWidget {
  const RevenueEmptyPeriod({super.key, required this.period});

  final RevenuePeriod period;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: context.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            period == RevenuePeriod.allTime
                ? 'لا توجد اشتراكات مدفوعة بعد'
                : 'لا توجد اشتراكات مدفوعة في ${period.label}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
          ),
        ],
      ),
    );
  }
}
