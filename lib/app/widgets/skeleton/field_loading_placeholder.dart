import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import 'skeleton_shapes.dart';

/// Stands in for a dropdown whose options are loading: a field-shaped
/// skeleton while loading, and a one-line retry when loading failed (so a
/// failure never leaves an endless placeholder).
class FieldLoadingPlaceholder extends StatelessWidget {
  const FieldLoadingPlaceholder({
    super.key,
    required this.failed,
    required this.onRetry,
    this.labelWidth = 90,
  });

  final bool failed;
  final VoidCallback onRetry;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    if (!failed) return FormFieldSkeleton(labelWidth: labelWidth);
    return Row(
      children: [
        Expanded(
          child: Text(
            'تعذر تحميل الخيارات',
            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.greyDark),
          ),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(
            'إعادة المحاولة',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
