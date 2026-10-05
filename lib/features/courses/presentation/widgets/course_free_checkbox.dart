import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IsFreeCourseTile extends StatelessWidget {
  const IsFreeCourseTile({
    super.key,
    required this.isFreeNotifier,
    this.title,
    this.description,
    this.enabled = true,
  });

  final ValueNotifier<bool> isFreeNotifier;

  final String? title;
  final String? description;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFreeNotifier,
      builder: (context, isFree, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFree
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: CheckboxListTile(
            value: isFree,
            onChanged: enabled
                ? (value) {
                    isFreeNotifier.value = value ?? false;
                  }
                : null,
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              title ?? 'الدورة مجانية',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              description ??
                  'عند تفعيل هذا الخيار سيتمكن الطلاب من الوصول إلى الدورة مجاناً',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        );
      },
    );
  }
}
