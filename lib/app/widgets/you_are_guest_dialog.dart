import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/design/app_assets.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di/di_container.dart';
import '../../core/storage/prefs_repository.dart';
import 'logout_confirmation_dialog.dart';

Future<void> showGuestContentDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => YouAreGuestDialog(),
  );
}

class YouAreGuestDialog extends StatelessWidget {
  const YouAreGuestDialog({super.key});

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
              SvgPicture.asset(AppAssets.iconUser, height: 40),
              const SizedBox(height: 14),
              Text(
                "قم بتسجيل الدخول للوصول لهذه الميزة",
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
                label: "تسجيل الدخول",
                onPressed: () {
                  context.pop();
                  goToLogin(context);
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

  Future<void> goToLogin(BuildContext context) async {
    await GetIt.I<PrefsRepository>().clearUser();
    clearAllBlocs();
    await resetDependencies();
    GetIt.I<PrefsRepository>().setOnBoardingSeen(true);
    if (context.mounted) {
      context.go(GRouter.config.applicationRoutes.login);
    }
  }
}
