import 'package:coursaty_student_and_teacher/app/widgets/delete_from_download_dialo.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_padding.dart';

class ContentItem extends StatelessWidget {
  const ContentItem({
    super.key,
    required this.index,
    required this.onTap,
    this.iconPath,
    required this.title,
    required this.actions,
    this.itemColor,
    this.onEdit,
    this.onDelete,
    this.size,
    this.fileUrl,
    this.isExist = false,
    required this.isVideo,
  });

  final Color? itemColor;
  final String? iconPath;
  final int index;
  final void Function() onTap;
  final String title;
  final List<Widget> actions;
  final Function()? onEdit, onDelete;
  final String? size;
  final bool isExist;
  final String? fileUrl;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final quality = GetIt.I<PrefsRepository>().getQuality(fileUrl ?? '');
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 10.22,
              offset: Offset(0, 2.5),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightTrack),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 80),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(12),
                    bottomStart: Radius.circular(12),
                  ),
                  color:
                      itemColor ??
                      [
                        Theme.of(context).colorScheme.primary,
                        AppColors.secondary,
                      ][index % 2],
                ),
                child: Center(
                  child: Padding(
                    padding: HWEdgeInsets.symmetric(horizontal: 12.0),
                    child: iconPath != null
                        ? SvgPicture.asset(
                            iconPath!,
                            color: Theme.of(context).colorScheme.onPrimary,
                            height: 15,
                          )
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            itemColor ??
                            Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (isVideo && isExist && quality != null) ...[
                      5.verticalSpace,
                      Text(
                        "الدقة: $quality",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      actions[i],
                      if (i != actions.length - 1) ...[
                        5.horizontalSpace,
                        SizedBox(
                          height: 30,
                          child: VerticalDivider(
                            color: AppColors.greyLight,
                            width: 1,
                          ),
                        ),
                        5.horizontalSpace,
                      ],
                    ],
                  ],
                ),
              ),
              if (onEdit != null) ...{
                InkWell(onTap: onEdit, child: Icon(Icons.edit)),
                10.horizontalSpace,
              },
              if (onDelete != null || isExist) ...{
                InkWell(
                  onTap:
                      onDelete ??
                      () {
                        _deleteConfirmation(context);
                      },
                  child: Icon(Icons.delete, color: Colors.red),
                ),
                10.horizontalSpace,
              },
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteConfirmation(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DeleteFromDownloadDialo(
        isVideo: isVideo,
        onConfirmed: () {
          context.pop();
          if (fileUrl != null) {
            GetIt.I<MyDownloadsBloc>().add(
              DeleteReferenceOfDownloadedFile(fileUrl: fileUrl!),
            );
          }
        },
      ),
    );
  }
}
