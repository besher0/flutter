import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/common/constant/design/app_assets.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/responsive_padding.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';

class RevenueHeroCard extends StatelessWidget {
  const RevenueHeroCard({
    super.key,
    required this.monthName,
    required this.total,
  });

  final String monthName;
  final String total;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.updateProfileStatus != c.updateProfileStatus,
      builder: (context, state) {
        return Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: HWEdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$total ل.س',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'إجمالي إيرادات شهر $monthName',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                AppAssets.iconCoins,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFF9E3C4),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SmallMetricCard extends StatelessWidget {
  const SmallMetricCard({
    super.key,
    required this.value,
    required this.label,
    this.amber = false,
  });

  final String value;
  final String label;
  final bool amber;

  @override
  Widget build(BuildContext context) {
    final color = amber ? AppColors.secondary : AppColors.primary;
    final layersUrl = AppAssets.iconLayers;
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                layersUrl,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ],
          ),
          Spacer(),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
