import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/data/model/sale_point_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/zoomable_image.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/common/helper/helper_functions.dart';
import '../../../../core/theme/app_colors.dart';

class PointOfSaleDetailScreen extends StatelessWidget {
  const PointOfSaleDetailScreen({super.key, required this.salePoint});

  final SalePoint salePoint;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: TitleAppBar(title: "تفاصيل نقطة البيع"),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ZoomableImage(
                        imageUrl: salePoint.image ?? '',
                        height: 111,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        salePoint.name ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ChipWidget(
                              text: salePoint.address ?? '',
                              iconPath: AppAssets.iconLocation,
                              iconColor: AppColors.secondary,
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {
                                HelperFunctions.openCallApp(
                                  salePoint.phone ?? '',
                                );
                              },
                              child: ChipWidget(
                                text: salePoint.phone ?? '',
                                iconPath: AppAssets.iconCall,
                                iconColor: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, color: AppColors.primaryLightTrack),
                      const SizedBox(height: 16),
                      Text(
                        'وصف الموقع',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sectionTitle,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        salePoint.description ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyDarkActive,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (salePoint.imageLocation != null) ...{
                        Divider(height: 1, color: AppColors.primaryLightTrack),
                        const SizedBox(height: 16),
                        Text(
                          'الموقع على الخارطة',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sectionTitle,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 9),
                        ZoomableImage(
                          imageUrl: salePoint.imageLocation ?? '',
                          height: 192,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      },
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    height: 111,
    decoration: BoxDecoration(
      color: AppColors.primaryLightTrack,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(Icons.image_outlined, color: AppColors.greyNormal, size: 48),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.iconPath});

  final String text;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkActive,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(
            iconPath,
            height: 12,
            color: AppColors.primaryDarkActive,
          ),
        ],
      ),
    );
  }
}
