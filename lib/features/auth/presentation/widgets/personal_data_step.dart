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
    required this.teacherInstagram,
  });

  final bool isForTeacher;
  final bool isActiveStep;
  final TextEditingController description, teacherInstagram;
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
          label: 'ط§ظ„ط§ط³ظ…',
          hint: 'ط§ظ„ط§ط³ظ…',
          controller: nameController,
          textInputAction: TextInputAction.next,
          validator: isActiveStep ? requiredValidator : null,
        ),
        const SizedBox(height: 16),
        CoursatyTextField(
          label: 'ط§ظ„ظƒظ†ظٹط©',
          hint: 'ط§ظ„ظƒظ†ظٹط©',
          controller: lastNameController,
          textInputAction: TextInputAction.next,
          validator: isActiveStep ? requiredValidator : null,
        ),
        const SizedBox(height: 16),
        CoursatyTextField(
          label: 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ',
          hint: 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ',
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
          label: 'ط§ظ„ط¬ظ†ط³',
          hint: 'ط§ظ„ط¬ظ†ط³',
          value: gender,
          onChanged: onGenderChanged,
          validator: isActiveStep
              ? (v) => v == null || v.isEmpty
                    ? 'ظ‡ط°ط§ ط§ظ„ط­ظ‚ظ„ ظ…ط·ظ„ظˆط¨'
                    : null
              : null,
          items: const [
            DropdownMenuItem(value: 'MALE', child: Text('ط°ظƒط±')),
            DropdownMenuItem(value: 'FEMALE', child: Text('ط£ظ†ط«ظ‰')),
          ],
        ),
        if (isForTeacher) ...{
          const SizedBox(height: 16),
          CoursatyTextField(
            label: 'ط§ظ„ظˆطµظپ',
            hint: 'ط§ظ„ظˆطµظپ',
            controller: description,
            textInputAction: TextInputAction.next,
            validator: isActiveStep ? requiredValidator : null,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'ط±ط§ط¨ط· طµظپط­ط© ط§ظ„ط§ظ†ط³طھط؛ط±ط§ظ… (ط§ط®طھظٹط§ط±ظٹ)',
            hint: 'ط±ط§ط¨ط· طµظپط­ط© ط§ظ„ط§ظ†ط³طھط؛ط±ط§ظ… (ط§ط®طھظٹط§ط±ظٹ)',
            controller: teacherInstagram,
          ),
        },
        const SizedBox(height: 24),
      ],
    );
  }
}
