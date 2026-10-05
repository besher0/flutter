import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MediaItem extends StatelessWidget {
  const MediaItem({
    super.key,
    required this.color,
    required this.title,
    required this.assetUrl,
    required this.onTap,
    this.isSvg = false,
  });

  final Color color;
  final String title;
  final String assetUrl;
  final void Function() onTap;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            isSvg
                ? CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: SvgPicture.asset(assetUrl),
                  )
                : Image.asset(assetUrl),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Icon(
              Icons.arrow_circle_left_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
