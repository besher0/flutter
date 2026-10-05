import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:coursaty_student_and_teacher/features/norifications/data/model/notification_model.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/date_time.dart';
import '../../../app_links_navigations.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.item,
    required this.fromTeacher,
  });

  final Notification item;
  final bool fromTeacher;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.link == null
          ? null
          : () {
              if (fromTeacher) {
                navigateFromUriForTeacher(Uri.parse(item.link!));
              } else {
                navigateFromUri(Uri.parse(item.link!));
              }
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.link == null
                    ? [
                        Theme.of(context).colorScheme.primary,
                        AppColors.primaryDarkActive,
                        const Color(0xFFC61F1F),
                      ][Random().nextInt(3)]
                    : Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconBell,
                height: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item.link == null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        item.createdAt?.dmy ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyNormal,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyNormal,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
