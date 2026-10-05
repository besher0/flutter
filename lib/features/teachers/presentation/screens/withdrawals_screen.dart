import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_withdrawal_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TeacherWithdrawalsScreen extends StatefulWidget {
  const TeacherWithdrawalsScreen({super.key});

  @override
  State<TeacherWithdrawalsScreen> createState() =>
      _TeacherWithdrawalsScreenState();
}

class _TeacherWithdrawalsScreenState extends State<TeacherWithdrawalsScreen> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<TeachersBloc>(
      context,
    ).add(GetWithdrawalsEvent(reset: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "السحوبات المالية"),
      body: SafeArea(
        child: BlocBuilder<TeachersBloc, TeachersState>(
          buildWhen: (p, c) =>
              p.withdrawalsPagination.paginationStatus !=
              c.withdrawalsPagination.paginationStatus,
          builder: (context, state) {
            final model = state.teacherWithdrawalModel;
            final withdrawals = model?.withdrawals ?? [];

            return state.withdrawalsPagination.isLoading &&
                    state.withdrawalsPagination.items.isEmpty
                ? Center(child: CoursatyAppLoader())
                : withdrawals.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد بيانات سحب',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<TeachersBloc>(
                        context,
                      ).add(GetWithdrawalsEvent(reset: true));
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                            (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                          BlocProvider.of<TeachersBloc>(
                            context,
                          ).add(GetWithdrawalsEvent(reset: false));
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverToBoxAdapter(
                              child: _WithdrawalSummaryCard(model: model),
                            ),
                          ),

                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList.separated(
                              itemCount: withdrawals.length,
                              itemBuilder: (context, index) {
                                final withdrawal = withdrawals[index];

                                return _WithdrawalCard(
                                  withdrawal: withdrawal,
                                  index: index,
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child:
                                state.withdrawalsPagination.isLoading &&
                                    state.withdrawalsPagination.items.isNotEmpty
                                ? Center(child: CoursatyAppLoader())
                                : SizedBox.shrink(),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class _WithdrawalSummaryCard extends StatelessWidget {
  const _WithdrawalSummaryCard({required this.model});

  final TeacherWithdrawalModel? model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.colorScheme.surface,
        border: Border(right: BorderSide(color: context.colorScheme.primary)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الأرباح والسحوبات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    title: 'إجمالي الأرباح',
                    value:
                        'ل.س ${(model?.teacherEarnings ?? 0).toStringAsFixed(2)}',
                  ),
                ),

                Expanded(
                  child: _InfoItem(
                    title: 'المبلغ المسحوب',
                    value: 'ل.س ${(model?.withdrawnAmount ?? 0).toString()}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    title: 'المبلغ المتبقي',
                    value:
                        'ل.س ${(model?.remainingAmount ?? 0).toStringAsFixed(2)}',
                  ),
                ),

                Expanded(
                  child: _InfoItem(
                    title: 'عدد السحوبات',
                    value: '${model?.pagination?.total ?? 0}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  const _WithdrawalCard({required this.withdrawal, required this.index});

  final Withdrawal withdrawal;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = (index & 1 == 0)
        ? context.colorScheme.primary
        : AppColors.secondary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.colorScheme.surface,
        border: Border(right: BorderSide(color: color)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// رقم السحب
            Text(
              'عملية سحب مالية',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),

            const SizedBox(height: 10),

            _SingleLineInfo(title: 'رقم العملية', value: withdrawal.id ?? '-'),

            const SizedBox(height: 10),

            _SingleLineInfo(
              title: 'تاريخ السحب',
              value: _formatDate(withdrawal.createdAt),
            ),

            const SizedBox(height: 18),

            Text(
              'تفاصيل السحب',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.greyNormal,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    title: 'المبلغ',
                    value: 'ل.س ${(withdrawal.amount ?? 0).toString()}',
                  ),
                ),

                Expanded(
                  child: _InfoItem(
                    title: 'الحالة',
                    value: _mapStatus(withdrawal.status),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

String _mapStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return 'قيد الانتظار';

    case 'approved':
      return 'مكتمل';

    case 'rejected':
      return 'مرفوض';

    case 'cancelled':
      return 'ملغي';

    default:
      return status ?? '-';
  }
}
