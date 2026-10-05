import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/screens/receipt_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class InterestsTab extends StatelessWidget {
  const InterestsTab({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SubscriptionBloc, SubscriptionState>(
        buildWhen: (previous, current) =>
            previous.interestsStatus != current.interestsStatus ||
            previous.interests != current.interests,
        builder: (context, state) {
          if (state.interestsStatus.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.interestsStatus.isFailed) {
            return const _InterestFeedback(
              message: 'تعذر تحميل اهتماماتك. اسحب لإعادة المحاولة.',
            );
          }
          if (state.interests.isEmpty) {
            return const _InterestFeedback(
              message: 'لا توجد كورسات محفوظة في اهتماماتك بعد.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<SubscriptionBloc>().add(LoadCourseInterests()),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.interests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _InterestCard(interest: state.interests[index]),
            ),
          );
        },
      );
}

class _InterestFeedback extends StatelessWidget {
  const _InterestFeedback({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async =>
        context.read<SubscriptionBloc>().add(LoadCourseInterests()),
    child: ListView(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * .18),
        Icon(
          Icons.bookmark_border,
          size: 58,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 15),
        ),
      ],
    ),
  );
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.interest});
  final CourseInterest interest;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pending = interest.pendingRequest?.isPending ?? false;
    final waitingReceipt = interest.isAwaitingReceipt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    interest.course.imageUrl == null ||
                        interest.course.imageUrl!.isEmpty
                    ? Container(
                        width: 62,
                        height: 62,
                        color: colors.primaryContainer,
                        child: const Icon(Icons.school_outlined),
                      )
                    : CachedNetworkImage(
                        imageUrl: interest.course.imageUrl!,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const SizedBox(
                          width: 62,
                          height: 62,
                          child: Icon(Icons.school_outlined),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interest.course.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusBadge(
                      isPending: pending,
                      isWaitingReceipt: waitingReceipt,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (waitingReceipt)
            Row(
              children: [
                Expanded(
                  child: CoursatyPrimaryButton(
                    label: 'رفع الإيصال',
                    onPressed: () => context.pushPage(
                      ReceiptUploadScreen(
                        courseId: interest.courseId,
                        courseName: interest.course.name,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'إزالة من اهتماماتي',
                  onPressed: () => context.read<SubscriptionBloc>().add(
                    RemoveCourseInterest(interest.courseId),
                  ),
                  icon: const Icon(Icons.bookmark_remove_outlined),
                ),
              ],
            )
          else if (pending)
            OutlinedButton.icon(
              onPressed: () => _showRequestDetails(context),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('عرض تفاصيل الطلب'),
            ),
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context) {
    final request = interest.pendingRequest!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلب الاشتراك',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text('تم استلام الإيصال وهو الآن قيد مراجعة الإدارة.'),
            if (request.adminNote != null && request.adminNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('ملاحظة: ${request.adminNote}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPending, required this.isWaitingReceipt});
  final bool isPending;
  final bool isWaitingReceipt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = isPending
        ? 'قيد المراجعة'
        : isWaitingReceipt
        ? 'بانتظار رفع الإيصال'
        : 'تم تحديث الطلب';
    final icon = isPending
        ? Icons.hourglass_top_outlined
        : Icons.upload_file_outlined;
    return Semantics(
      label: text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colors.onSecondaryContainer),
            const SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
