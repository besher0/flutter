import 'package:flutter/material.dart';

import '../../../../app/widgets/coursaty_text_field.dart';

class PasswordStep extends StatelessWidget {
  const PasswordStep({
    required this.isActiveStep,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.passwordValidator,
  });

  final bool isActiveStep;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final FormFieldValidator<String> passwordValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CoursatyTextField(
          label: 'كلمة المرور',
          hint: '*********',
          controller: passwordController,
          withObscureText: true,
          validator: isActiveStep ? passwordValidator : null,
        ),
        const SizedBox(height: 16),
        CoursatyTextField(
          label: 'تأكيد كلمة المرور',
          hint: '*********',
          controller: passwordConfirmController,
          withObscureText: true,
          validator: isActiveStep
              ? (v) {
                  final confirm = v ?? '';
                  if (confirm.trim().isEmpty) return 'تأكيد كلمة المرور مطلوب';
                  if (confirm.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  if (confirm != passwordController.text) return 'غير متطابقة';
                  return null;
                }
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
