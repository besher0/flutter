import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/widgets/coursaty_button.dart';
import 'app/widgets/logout_confirmation_dialog.dart';
import 'core/routes/router.dart';
import 'core/theme/app_colors.dart';

/// Shown on Windows to a student account: the desktop version is for
/// teachers for now. The student can sign out (to sign in with a teacher
/// account) or reach the support contacts.
class StudentDesktopUnavailablePage extends StatelessWidget {
  const StudentDesktopUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLightTrack,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.desktop_access_disabled_rounded,
                        size: 60,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'نسخة الويندوز للطالب غير متوفرة بعد',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تواصل مع الدعم للمزيد من التفاصيل',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const SizedBox(height: 36),
                    CoursatyPrimaryButton(
                      label: 'تواصل مع الدعم',
                      onPressed: () => context.push(
                        GRouter.config.applicationRoutes.contactUs,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const LogoutConfirmationDialog(),
                      ),
                      icon: Icon(Icons.logout, color: colors.error),
                      label: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w600,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
