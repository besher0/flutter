import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/design/app_assets.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/feature_flags.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/app/widgets/subscribe_to_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showPaidContentDialog(
  BuildContext context, {
  required String courseId,
}) async {
  if (!SubscriptionFeatureFlags.showLegacySubscriptionMethods) {
    await showSubscribeToCourseDialog(context, courseId: courseId);
    return;
  }
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => PaidContentDialog(),
  );
}

class PaidContentDialog extends StatelessWidget {
  const PaidContentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 14),
              SvgPicture.asset(AppAssets.iconLock, height: 40),
              const SizedBox(height: 14),
              Text(
                "عذراً لايمكنك الوصول للمحتوى لأن المحتوى مدفوع",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              CoursatyPrimaryButton(
                label: "شراء كود",
                onPressed: () {
                  context.pop();
                  context.push(GRouter.config.applicationRoutes.pointsOfSale);
                },
              ),
              const SizedBox(height: 12),
              CoursatySecondaryButton(
                label: "رجوع",
                onPressed: () {
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
