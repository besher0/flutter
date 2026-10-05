import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Dropdown field matching Coursaty text field style (RTL, same border/shadow).
class CoursatyDropdown<T> extends StatelessWidget {
  const CoursatyDropdown({
    super.key,
    this.label,
    this.value,
    required this.items,
    this.hint,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
        ],
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            boxShadow: [AppColors.inputShadow],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            isExpanded: true,
            autofocus: false,
            alignment: Alignment.centerRight,
            dropdownColor: Theme.of(context).colorScheme.surface,
            hint: Text(
              hint ?? label ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.greyNormal,
              ),
              textAlign: TextAlign.right,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
