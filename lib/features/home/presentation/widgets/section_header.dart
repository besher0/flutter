import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.showMore = true,
    this.onMoreTap,
    this.color,
  });

  final String title;
  final bool showMore;
  final VoidCallback? onMoreTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
            height: 1.4,
          ),
        ),
        if (showMore)
          GestureDetector(
            onTap: onMoreTap,
            child: Text(
              'المزيد',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
                height: 1.4,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
