import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/paid_content_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/design/app_assets.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/you_are_guest_dialog.dart';
import '../../../../core/storage/prefs_repository.dart';

class _RatingDialog extends StatefulWidget {
  const _RatingDialog({required this.courseId});

  final String courseId;

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int selectedStars = 1; // ✅ minimum 1

  void _selectStar(int index) {
    setState(() {
      selectedStars = index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Text(
                'تقييم',
                style: GoogleFonts.cairo(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'نشكر تفاعلك معنا  \n من فضلك، قيم لنا الكورس  من 5',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // ⭐ Stars
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isActive = index < selectedStars;

                    return InkWell(
                      onTap: () => _selectStar(index),
                      child: SvgPicture.asset(
                        AppAssets.iconStar,
                        height: 32,
                        color: isActive ? Color(0xffECA541) : null,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              CoursatyPrimaryButton(
                label: "حفظ",
                onPressed: () {
                  BlocProvider.of<CoursesBloc>(context).add(
                    RateCourseEvent(
                      stars: selectedStars,
                      courseId: widget.courseId,
                    ),
                  );
                  context.pop();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.courseId,
    required this.isFreeCourse,
  });

  final bool isFreeCourse;
  final String courseId;

  void _openRatingDialog(BuildContext context, bool ratedByMe) async {
    if (GetIt.I<PrefsRepository>().isGuest) {
      showGuestContentDialog(context);
      return;
    }
    if (ratedByMe) {
      return;
    }
    if (await HelperFunctions.lostInternetConnection()) {
      showMessage("لايوجد اتصال بالانترنت");
      return;
    }
    if (context.mounted) {
      List<String> activeCourses = context
          .read<MyDownloadsBloc>()
          .state
          .courseIdToCourseDetailsReferences
          .keys
          .toList();
      if (!activeCourses.any((item) => item == courseId)) {
        showPaidContentDialog(context, courseId: courseId);
        return;
      }
      await showDialog<int>(
        context: context,
        builder: (_) => _RatingDialog(courseId: courseId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      buildWhen: (p, c) =>
          p.rateCourseOrGetCourseRateStatus !=
          c.rateCourseOrGetCourseRateStatus,
      builder: (context, state) {
        if (state.rateCourseOrGetCourseRateStatus.isLoading) {
          return Center(child: CoursatyAppLoader());
        }
        if (state.courseRatingModel == null) {
          return SizedBox.shrink();
        }
        return InkWell(
          onTap: () => _openRatingDialog(
            context,
            state.courseRatingModel!.isRatedByUser ?? false,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Color(0xffF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  (state.courseRatingModel!.isRatedByUser ?? false)
                      ? Icons.star_outlined
                      : Icons.star_border_outlined,
                  color: Color(0xffECA541),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  (state.courseRatingModel!.averageRating ?? 0).toStringAsFixed(
                    1,
                  ),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${state.courseRatingModel!.totalRatings ?? 0})',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
