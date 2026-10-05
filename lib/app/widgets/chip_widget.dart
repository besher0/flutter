import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class ChipWidget extends StatelessWidget {
  const ChipWidget({this.text, required this.iconPath, this.iconColor});

  final String? text;
  final String iconPath;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 12.5,
            color: iconColor ?? AppColors.primaryDarkActive,
          ),
          if (text != null) ...{
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarkActive,
                  height: 1.4,
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
