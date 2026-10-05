import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/widgets/coursaty_dropdown.dart';
import '../../../../app/widgets/coursaty_text_field.dart';

class PersonalDataStep extends StatelessWidget {
  const PersonalDataStep({
    super.key,
    required this.isActiveStep,
    required this.isForTeacher,
    required this.description,
    required this.nameController,
    required this.lastNameController,
    required this.phoneController,
    required this.gender,
    required this.onGenderChanged,
    required this.requiredValidator,
    required this.phoneValidator,
    required this.teacherTelegram,
    required this.teacherInstagram,
  });

  final bool isForTeacher;
  final bool isActiveStep;
  final TextEditingController description, teacherTelegram, teacherInstagram;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final String? gender;
  final ValueChanged<String?> onGenderChanged;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> phoneValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CoursatyTextField(
          label: 'الاسم',
          hint: 'الاسم',
          controller: nameController,
          textInputAction: TextInputAction.next,
          validator: isActiveStep ? requiredValidator : null,
        ),
        const SizedBox(height: 16),
        CoursatyTextField(
          label: 'الكنية',
          hint: 'الكنية',
          controller: lastNameController,
          textInputAction: TextInputAction.next,
          validator: isActiveStep ? requiredValidator : null,
        ),
        const SizedBox(height: 16),
        CoursatyTextField(
          label: 'رقم الهاتف',
          hint: 'رقم الهاتف',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: isActiveStep ? phoneValidator : null,
        ),
        const SizedBox(height: 16),
        CoursatyDropdown<String>(
          label: 'الجنس',
          hint: 'الجنس',
          value: gender,
          onChanged: onGenderChanged,
          validator: isActiveStep
              ? (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null
              : null,
          items: const [
            DropdownMenuItem(value: 'MALE', child: Text('ذكر')),
            DropdownMenuItem(value: 'FEMALE', child: Text('أنثى')),
          ],
        ),
        if (isForTeacher) ...{
          const SizedBox(height: 16),
          CoursatyTextField(
            label: 'الوصف',
            hint: 'الوصف',
            controller: description,
            textInputAction: TextInputAction.next,
            validator: isActiveStep ? requiredValidator : null,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'رابط قناة التلفرام',
            hint: 'رابط قناة التلفرام',
            controller: teacherTelegram,
            validator: requiredValidator,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'رابط صفحة الانستغرام (اختياري)',
            hint: 'رابط صفحة الانستغرام (اختياري)',
            controller: teacherInstagram,
          ),
        },
        const SizedBox(height: 24),
      ],
    );
  }
}
