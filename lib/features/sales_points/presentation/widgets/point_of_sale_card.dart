import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/common/helper/helper_functions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/sale_point_model.dart';

class PointOfSaleCard extends StatelessWidget {
  const PointOfSaleCard({super.key, required this.salePoint});

  final SalePoint salePoint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          GRouter.config.applicationRoutes.pointOfSaleDetails,
          extra: salePoint,
        );
      },
      child: Container(
        width: 1.sw - 40,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightTrack, width: 0.85),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: salePoint.image ?? '',
                width: 157,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(157, 83),
                errorWidget: (_, __, ___) => _placeholder(157, 83),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    salePoint.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      ChipWidget(
                        text: salePoint.address ?? '',
                        iconPath: AppAssets.iconLocation,
                        iconColor: AppColors.secondary,
                      ),
                      InkWell(
                        onTap: () {
                          HelperFunctions.openCallApp(salePoint.phone ?? '');
                        },
                        child: ChipWidget(
                          text: salePoint.phone ?? '',
                          iconPath: AppAssets.iconCall,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double w, double h) => Container(
    width: w,
    height: h,
    color: AppColors.primaryLightTrack,
    child: Icon(Icons.image_outlined, color: AppColors.greyNormal, size: 32),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.iconPath});

  final String text;
  final String iconPath;

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
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDarkActive,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 5),
          SvgPicture.asset(
            iconPath,
            height: 11,
            color: AppColors.primaryDarkActive,
          ),
        ],
      ),
    );
  }
}
