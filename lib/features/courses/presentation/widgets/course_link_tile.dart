import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// A plain link on the course page: the app's icon and its name, no button
/// background (Telegram channel, Instagram page, the teacher's group).
class CourseLinkTile extends StatelessWidget {
  const CourseLinkTile({
    super.key,
    required this.title,
    required this.assetUrl,
    required this.onTap,
    this.isSvg = false,
  });

  final String title;
  final String assetUrl;
  final VoidCallback onTap;
  final bool isSvg;

  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: _iconSize,
              child: isSvg
                  ? SvgPicture.asset(assetUrl)
                  : Image.asset(assetUrl, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
