import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class TeacherCard extends StatelessWidget {
  const TeacherCard({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    this.coursesCount = '+40 كورس',
    this.likesCount = '12',
    this.onTap,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String coursesCount;
  final String likesCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightTrack, width: 0.85),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(180),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.primaryLightTrack,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.primaryLightTrack,
                  child: Icon(
                    Icons.person,
                    color: AppColors.greyNormal,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(flex: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Chip(text: coursesCount, iconPath: AppAssets.iconBook),
                const SizedBox(width: 14),
                BlocBuilder<TeachersBloc, TeachersState>(
                  buildWhen: (p, c) =>
                      p.interactionsStatus[id] != c.interactionsStatus[id],
                  builder: (context, state) {
                    bool isLiked = state.likedTeachers.any(
                      (item) => item.id == id,
                    );
                    return (state.interactionsStatus[id]?.isLoading ?? false)
                        ? CoursatyAppLoader()
                        : _Chip(
                            text: likesCount,
                            iconPath: isLiked
                                ? AppAssets.iconHeartFilled
                                : AppAssets.iconHeart,
                            iconColor: const Color(0xFFC61F1F),
                          );
                  },
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.iconPath, this.iconColor});

  final String text;
  final String iconPath;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkActive,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 5),
          SvgPicture.asset(
            iconPath,
            height: 12.5,
            color: iconColor ?? AppColors.primaryDarkActive,
          ),
        ],
      ),
    );
  }
}
