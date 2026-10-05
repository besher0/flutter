import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Compact teacher item for horizontal list: circular avatar + name.
/// Matches Figma Frame 2147225141 (e.g. 91:5551).
class TeacherAvatarName extends StatelessWidget {
  const TeacherAvatarName({
    super.key,
    required this.name,
    required this.imageUrl,
    this.onTap,
  });

  final String name;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(34.5),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 69,
                height: 69,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 69,
                  height: 69,
                  color: AppColors.primaryLightTrack,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 69,
                  height: 69,
                  color: AppColors.primaryLightTrack,
                  child: Icon(
                    Icons.person,
                    color: AppColors.greyNormal,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,

              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
