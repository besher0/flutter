import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/coursaty_button.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/theme/app_colors.dart';

/// Success screen after sign-up: icon, welcome message, CTA button.
class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key, required this.isForTeacher});

  final bool isForTeacher;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  isForTeacher
                      ? AppAssets.waitingIllustration
                      : AppAssets.successIllustration,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightTrack,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  isForTeacher
                      ? "شكراً لطلبك أن تكون جزءاً من فريقنا"
                      : 'تم إنشاء حسابك بنجاح',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isForTeacher
                      ? " سندرس طلبكم ونقوم بالرد بأسرع وقت ممكن"
                      : 'مرحباً بك! جميع مزايا التطبيق جاهزة لتجربتها',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBody,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CoursatyPrimaryButton(
                  label: isForTeacher ? "تم" : 'تسجيل الدخول',
                  onPressed: () {
                    context.go(GRouter.config.applicationRoutes.login);
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
