import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
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
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TeachersBloc>(context).add(GetRevenuesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "إيراداتي"),
      body: SafeArea(
        child: BlocBuilder<TeachersBloc, TeachersState>(
          buildWhen: (p, c) => p.getRevenues != c.getRevenues,
          builder: (context, state) {
            final courses = state.teacherRevenueModel?.courses ?? [];
            final totals = state.teacherRevenueModel?.totals;
            return state.getRevenues.isLoading
                ? Center(child: CoursatyAppLoader())
                : courses.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد بيانات إيرادات',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<TeachersBloc>(
                        context,
                      ).add(GetRevenuesEvent());
                    },
                    child: CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverToBoxAdapter(
                            child: _TotalsCard(totals: totals),
                          ),
                        ),
                        if (state.teacherRevenueModel?.invoice != null)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: _InvoiceSummaryCard(
                                invoice: state.teacherRevenueModel!.invoice!,
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList.separated(
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];

                              final invoiceCourses =
                                  state.teacherRevenueModel?.invoice?.courses ??
                                  [];

                              final invoiceCourse =
                                  index < invoiceCourses.length
                                  ? invoiceCourses[index]
                                  : null;

                              return _CourseRevenueCard(
                                course: course,
                                index: index,
                                invoiceCourse: invoiceCourse,
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final Totals? totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.colorScheme.surface,
        border: Border(right: BorderSide(color: context.colorScheme.primary)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "الإجماليات",
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "إجمالي الإيرادات",
                  value: "${totals?.grossRevenue ?? 0} ل.س",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "إيراد المدرس",
                  value: "${totals?.teacherRevenue ?? 0} ل.س",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "إيراد المنصة",
                  value: "${totals?.adminRevenue ?? 0} ل.س",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "المشتركون",
                  value: "${totals?.subscribersCount ?? 0}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final s = invoice.summary;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ملخص الفاتورة",
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _SingleLineInfo(title: "العملة", value: invoice.currency ?? "-"),

          // _SingleLineInfo(
          //   title: "المنطقة الزمنية",
          //   value: invoice.timezone ?? "-",
          // ),
          const Divider(),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "إجمالي المشتركين",
                  value: "${s?.totalSubscribers ?? 0}",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "المشتركون الفريدون",
                  value: "${s?.uniqueSubscribersCount ?? 0}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "إجمالي الخصومات",
                  value: "${s?.totalDiscount ?? 0} ل.س",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "إجمالي الإيرادات",
                  value: "${s?.totalRevenues ?? 0} ل.س",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "إيراد المدرس",
                  value: "${s?.teacherRevenue ?? 0} ل.س",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "إيراد المنصة",
                  value: "${s?.platformRevenue ?? 0} ل.س",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class _TotalsCard extends StatelessWidget {
//   const _TotalsCard({required this.totals});
//
//   final Totals? totals;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: context.colorScheme.surface,
//         border: Border(right: BorderSide(color: context.colorScheme.primary)),
//         boxShadow: [
//           BoxShadow(
//             color: context.colorScheme.primary.withValues(alpha: 0.2),
//             offset: Offset(0, 4),
//             blurRadius: 10,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'الإجماليات',
//               style: GoogleFonts.cairo(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'إجمالي الإيرادات',
//                     value:
//                         ' ل.س ${(totals?.grossRevenue ?? 0).toStringAsFixed(2)}',
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'إيراد المدرّس',
//                     value:
//                         ' ل.س ${(totals?.teacherRevenue ?? 0).toStringAsFixed(2)}',
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'إيراد الإدارة',
//                     value:
//                         ' ل.س ${(totals?.adminRevenue ?? 0).toStringAsFixed(2)}',
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'عدد المشتركين',
//                     value: '${totals?.subscribersCount ?? 0}',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _CourseRevenueCard extends StatelessWidget {
  const _CourseRevenueCard({
    required this.course,
    required this.index,
    this.invoiceCourse,
  });

  final TeacherRevenueModelCourse course;
  final InvoiceCourse? invoiceCourse;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = course.course;
    final r = course.revenue;
    final rating = course.rating;

    final line = invoiceCourse?.lineItems?.isNotEmpty == true
        ? invoiceCourse!.lineItems!.first
        : null;

    final discount = line?.discount;

    final color = index.isEven
        ? context.colorScheme.primary
        : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.colorScheme.surface,
        border: Border(right: BorderSide(color: color)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c?.name ?? "-",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 16),

          _SingleLineInfo(
            title: "تاريخ النشر",
            value: _formatDate(c?.publishedAt),
          ),

          _SingleLineInfo(
            title: "تاريخ الانتهاء",
            value: _formatDate(c?.expiresAt),
          ),

          _SingleLineInfo(title: "السعر", value: "${c?.price ?? 0} ل.س"),

          _SingleLineInfo(
            title: "مكتملة",
            value: c?.isCompleted == true ? "نعم" : "لا",
          ),

          const Divider(height: 30),

          Text(
            "الإيرادات",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "قبل النسبة",
                  value: "${r?.beforePercentage ?? 0}",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "إيراد المدرس",
                  value: "${r?.teacherRevenue ?? 0}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "إيراد المنصة",
                  value: "${r?.adminRevenue ?? 0}",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "النسبة",
                  value:
                      "${r?.teacherPercentage ?? 0}% / ${r?.adminPercentage ?? 0}%",
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          Text(
            "الإحصائيات",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: "المشتركون",
                  value: "${course.subscribersCount ?? 0}",
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: "التقييم",
                  value:
                      "${rating?.average ?? 0} (${rating?.ratersCount ?? 0})",
                ),
              ),
            ],
          ),

          if (line != null) ...[
            const Divider(height: 30),

            Text(
              "تفاصيل الفاتورة",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _SingleLineInfo(
              title: "سعر الدورة",
              value: "${line.coursePrice ?? 0} ل.س",
            ),

            _SingleLineInfo(
              title: "المشتركون",
              value: "${line.subscribersCount ?? 0}",
            ),

            _SingleLineInfo(
              title: "المشتركون الفريدون",
              value: "${line.uniqueSubscribersCount ?? 0}",
            ),

            _SingleLineInfo(
              title: "الإجمالي",
              value: "${line.subtotal ?? 0} ل.س",
            ),

            _SingleLineInfo(
              title: "إيراد المدرس",
              value: "${line.teacherRevenue ?? 0} ل.س",
            ),

            _SingleLineInfo(
              title: "إيراد المنصة",
              value: "${line.platformRevenue ?? 0} ل.س",
            ),
          ],

          if (discount != null) ...[
            const Divider(height: 30),

            Text(
              "الخصومات",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _SingleLineInfo(
              title: "نسبة الخصم",
              value: "${discount.percentage ?? 0}%",
            ),

            _SingleLineInfo(
              title: "خصم لكل مشترك",
              value: "${discount.amountPerSubscriber ?? 0}",
            ),

            _SingleLineInfo(
              title: "إجمالي الخصومات",
              value: "${discount.totalAmount ?? 0}",
            ),

            _SingleLineInfo(
              title: "خصم الدورة",
              value: "${discount.courseAmountPerSubscriber ?? 0}",
            ),

            _SingleLineInfo(
              title: "خصم الكود",
              value: "${discount.codeAmountPerSubscriber ?? 0}",
            ),
          ],
        ],
      ),
    );
  }
}

// class _CourseRevenueCard extends StatelessWidget {
//   const _CourseRevenueCard({required this.course, required this.index});
//
//   final TeacherRevenueModelCourse course;
//   final int index;
//
//   @override
//   Widget build(BuildContext context) {
//     final courseInfo = course.course;
//     final revenue = course.revenue;
//     final rating = course.rating;
//     final color = (index & 1 == 0)
//         ? context.colorScheme.primary
//         : AppColors.secondary;
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: context.colorScheme.surface,
//         border: Border(right: BorderSide(color: color)),
//         boxShadow: [
//           BoxShadow(
//             color: context.colorScheme.primary.withValues(alpha: 0.2),
//             offset: Offset(0, 4),
//             blurRadius: 10,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// اسم الدورة
//             Text(
//               courseInfo?.name ?? 'دورة غير معروفة',
//               style: GoogleFonts.cairo(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// تاريخ النشر
//             _SingleLineInfo(
//               title: 'تاريخ النشر',
//               value: _formatDate(courseInfo?.publishedAt),
//             ),
//
//             const SizedBox(height: 18),
//
//             /// تفاصيل الإيرادات
//             Text(
//               'تفاصيل الإيرادات',
//               style: GoogleFonts.cairo(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.greyNormal,
//               ),
//             ),
//
//             const SizedBox(height: 14),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'قبل النسبة',
//                     value:
//                         ' ل.س ${(revenue?.beforePercentage ?? 0).toStringAsFixed(2)}',
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'نسبة المدرّس',
//                     value: '${revenue?.teacherPercentage ?? 0}%',
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'نسبة الإدارة',
//                     value: '${revenue?.adminPercentage ?? 0}%',
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'إيراد المدرّس',
//                     value:
//                         ' ل.س ${(revenue?.teacherRevenue ?? 0).toStringAsFixed(2)}',
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 18),
//
//             /// المشتركين والتقييم
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'عدد المشتركين',
//                     value: '${course.subscribersCount ?? 0}',
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: 'التقييم',
//                     value:
//                         '${(rating?.average ?? 0).toStringAsFixed(1)} (${rating?.ratersCount ?? 0})',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.greyNormal,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _SingleLineInfo extends StatelessWidget {
  const _SingleLineInfo({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.greyNormal,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';

  return DateFormat('yyyy/MM/dd').format(date);
}
