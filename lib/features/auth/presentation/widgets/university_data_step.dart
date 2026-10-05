import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/list_extensions.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/colleges_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/departments_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/universities_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable_generator/utils.dart';

import '../../../../app/widgets/coursaty_dropdown.dart';
import '../../../../app/widgets/coursaty_text_field.dart';
import '../../../../app/widgets/try_again_widget.dart';
import '../../data/model/education_model.dart';

class UniversityDataStep extends StatelessWidget {
  const UniversityDataStep({
    super.key,
    required this.universityNumberController,
    required this.universityController,
    required this.collegeController,
    required this.departmentController,
    required this.yearController,
    required this.isForTeacher,
    required this.isActiveStep,
    required this.educationInfo,
  });

  final bool isActiveStep;
  final bool isForTeacher;
  final EducationInfo educationInfo;
  final TextEditingController universityNumberController;
  final TextEditingController universityController;
  final TextEditingController collegeController;
  final TextEditingController departmentController;
  final TextEditingController yearController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return !state.getUniversities.isSuccess
                ? state.getUniversities.isFailed
                      ? TryAgainWidget(
                          onPress: () {
                            BlocProvider.of<AuthBloc>(
                              context,
                            ).add(GetUniversitiesEvent());
                          },
                        )
                      : Center(child: CoursatyAppLoader())
                : CoursatyDropdown<UniversitiesResponseModel>(
                    label: 'الجامعة',
                    hint: 'الجامعة',
                    onChanged: (item) {
                      if (item == null) return;
                      universityController.text = item.id!;
                      collegeController.text = '';
                      departmentController.text = '';
                      yearController.text = '';
                      educationInfo.universityName = item.name!;
                      BlocProvider.of<AuthBloc>(
                        context,
                      ).add(GetCollegesEvent(universityId: item.id!));
                    },
                    validator: _requiredValidator,
                    value: state.universitiesResponseModel?.firstWhereOrNull(
                      (e) => e.id == universityController.text,
                    ),
                    items:
                        state.universitiesResponseModel
                            ?.map(
                              (item) =>
                                  DropdownMenuItem<UniversitiesResponseModel>(
                                    value: item,
                                    child: Text(item.name ?? ''),
                                  ),
                            )
                            .toList() ??
                        [],
                  );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.getColleges.isInit) {
              return SizedBox.shrink();
            } else {
              return !state.getColleges.isSuccess
                  ? state.getColleges.isFailed
                        ? TryAgainWidget(
                            onPress: () {
                              BlocProvider.of<AuthBloc>(context).add(
                                GetCollegesEvent(
                                  universityId: universityController.text,
                                ),
                              );
                            },
                          )
                        : CoursatyAppLoader()
                  : CoursatyDropdown<CollegesResponseModel>(
                      label: 'الكلية',
                      hint: 'الكلية',
                      validator: _requiredValidator,
                      value: state.collegesResponseModel?.firstWhereOrNull(
                        (e) => e.id == collegeController.text,
                      ),
                      onChanged: (item) {
                        if (item == null) return;
                        collegeController.text = item.id!;
                        departmentController.text = '';
                        yearController.text = '';
                        educationInfo.collegeName = item.name!;
                        BlocProvider.of<AuthBloc>(
                          context,
                        ).add(GetDepartmentsEvent(collegeId: item.id!));
                        BlocProvider.of<AuthBloc>(
                          context,
                        ).add(GetAcademicYearsEvent(collegeId: item.id!));
                      },
                      items:
                          state.collegesResponseModel
                              ?.map(
                                (item) =>
                                    DropdownMenuItem<CollegesResponseModel>(
                                      value: item,
                                      child: Text(item.name ?? ''),
                                    ),
                              )
                              .toList() ??
                          [],
                    );
            }
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return state.getDepartments.isInit
                ? SizedBox.shrink()
                : !state.getDepartments.isSuccess
                ? state.getDepartments.isFailed
                      ? TryAgainWidget(
                          onPress: () {
                            BlocProvider.of<AuthBloc>(context).add(
                              GetDepartmentsEvent(
                                collegeId: collegeController.text,
                              ),
                            );
                          },
                        )
                      : CoursatyAppLoader()
                : state.departmentsResponseModel.isNullOrEmpty
                ? SizedBox.shrink()
                : CoursatyDropdown<DepartmentsResponseModel>(
                    label: 'القسم',
                    hint: 'القسم',
                    validator: _requiredValidator,
                    value: state.departmentsResponseModel?.firstWhereOrNull(
                      (e) => e.id == departmentController.text,
                    ),
                    onChanged: (item) {
                      if (item == null) return;
                      departmentController.text = item.id!;
                      educationInfo.departmentName = item.name!;
                      yearController.text = '';
                    },
                    items:
                        state.departmentsResponseModel
                            ?.map(
                              (item) =>
                                  DropdownMenuItem<DepartmentsResponseModel>(
                                    value: item,
                                    child: Text(item.name ?? ''),
                                  ),
                            )
                            .toList() ??
                        [],
                  );
          },
        ),
        if (!isForTeacher) ...{
          const SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state.getYears.isInit
                  ? SizedBox.shrink()
                  : !state.getYears.isSuccess
                  ? state.getYears.isFailed
                        ? TryAgainWidget(
                            onPress: () {
                              BlocProvider.of<AuthBloc>(context).add(
                                GetAcademicYearsEvent(
                                  collegeId: collegeController.text,
                                ),
                              );
                            },
                          )
                        : CoursatyAppLoader()
                  : CoursatyDropdown<AcademicYearsResponseModel>(
                      label: 'السنة',
                      hint: 'السنة',
                      value: state.academicYearsResponseModel?.firstWhereOrNull(
                        (e) => e.id == yearController.text,
                      ),
                      validator: _requiredValidator,
                      onChanged: (item) {
                        if (item == null) return;
                        yearController.text = item.id!;
                        educationInfo.yearName =
                            item.academicYear?.yearName ?? '';
                      },
                      items:
                          state.academicYearsResponseModel
                              ?.map(
                                (item) =>
                                    DropdownMenuItem<
                                      AcademicYearsResponseModel
                                    >(
                                      value: item,
                                      child: Text(
                                        item.academicYear?.yearName ?? '',
                                      ),
                                    ),
                              )
                              .toList() ??
                          [],
                    );
            },
          ),
        },
        if (!isForTeacher) ...{
          const SizedBox(height: 16),
          CoursatyTextField(
            label: 'الرقم الجامعي',
            hint: 'الرقم الجامعي',
            controller: universityNumberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: isActiveStep
                ? (text) {
                    if (text == null) {
                      return "الرقم الجامعي مطلوب";
                    }
                    if (int.tryParse(text) == null) {
                      return "الرقم الجامعي المدخل غير صالح";
                    }
                    return null;
                  }
                : null,
          ),
        },
        const SizedBox(height: 24),
      ],
    );
  }

  String? _requiredValidator(dynamic item) {
    if (item == null) {
      return "الحقل مطلوب";
    }
    return null;
  }
}
