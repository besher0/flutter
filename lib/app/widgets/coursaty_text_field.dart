import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class CoursatyTextField extends StatefulWidget {
  const CoursatyTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.withObscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.minLines = 1,
    this.inputFormatters,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool withObscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int minLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<CoursatyTextField> createState() => _CoursatyTextFieldState();
}

class _CoursatyTextFieldState extends State<CoursatyTextField> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            boxShadow: [AppColors.inputShadow],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              validator: widget.validator,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              minLines: widget.minLines,
              maxLines: widget.minLines + 1,
              inputFormatters: widget.inputFormatters,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onFieldSubmitted: widget.onFieldSubmitted,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hint ?? widget.label,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyNormal,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: widget.withObscureText
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      )
                    : widget.suffixIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
