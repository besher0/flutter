import 'package:coursaty_student_and_teacher/core/di/di_container.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/bloc/notifications_bloc.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/presentation/bloc/sales_points_bloc.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import '../../features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key, required this.onConfirmed});

  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  icon: Icon(Icons.close, color: Color(0xFFC61F1F)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 14),
              const Icon(
                Icons.delete_outline,
                color: Color(0xFFC61F1F),
                size: 40,
              ),
              const SizedBox(height: 14),
              Text(
                'هل أنت متأكد أنك تريد حذف الحساب؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFC61F1F),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x40C61F1F),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      onConfirmed.call();
                    },
                    child: Center(
                      child: Text(
                        'حذف الحساب',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: Text(
                        'رجوع',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.greyDark,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
