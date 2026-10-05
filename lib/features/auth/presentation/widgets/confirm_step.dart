import 'package:coursaty_student_and_teacher/core/common/constant/design/constant_design.dart';
import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/education_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class ConfirmStep extends StatelessWidget {
  const ConfirmStep({
    required this.name,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.educationInfo,
  });

  final String name;
  final String lastName;
  final String phone;
  final String gender;
  final EducationInfo educationInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DataSection(
          color: Theme.of(context).colorScheme.primary,
          title: "البيانات الشخصية",
          data: [
            _ConfirmRow(label: 'الاسم', value: name),
            _ConfirmRow(label: 'الكنية', value: lastName),
            _ConfirmRow(label: 'رقم الهاتف', value: phone),
            _ConfirmRow(label: 'الجنس', value: getGenderTranslation(gender)),
          ],
        ),
        const SizedBox(height: 24),
        _DataSection(
          color: AppColors.secondary,
          title: "البيانات الجامعية",
          data: [
            _ConfirmRow(label: 'الجامعة', value: educationInfo.universityName),
            _ConfirmRow(label: 'الكلية', value: educationInfo.collegeName),
            _ConfirmRow(label: 'القسم', value: educationInfo.departmentName),
            _ConfirmRow(label: 'السنة', value: educationInfo.yearName),
          ],
        ),
      ],
    );
  }

  String getGenderTranslation(String gender) {
    switch (gender) {
      case "MALE":
        return "ذكر";
      default:
        return "أنثى";
    }
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textBody,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  const _DataSection({
    required this.title,
    required this.color,
    required this.data,
  });

  final String title;
  final Color color;
  final List<Widget> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: HWEdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kr12),
        border: Border(right: BorderSide(color: color)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
          20.verticalSpace,
          ...data,
        ],
      ),
    );
  }
}
