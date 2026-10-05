import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/list_extensions.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/update_student_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/coursaty_dropdown.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

class ChangeUniversityScreen extends StatefulWidget {
  const ChangeUniversityScreen({super.key, required this.isForChangeYear});

  final bool isForChangeYear;

  @override
  State<ChangeUniversityScreen> createState() => _ChangeUniversityScreenState();
}

class _ChangeUniversityScreenState extends State<ChangeUniversityScreen> {
  final TextEditingController universityController = TextEditingController();

  final TextEditingController collegeController = TextEditingController();

  final TextEditingController departmentController = TextEditingController();

  final TextEditingController yearController = TextEditingController();

  late final String initialUniversityId;
  late final String initialCollegeId;
  late final String initialDepartmentId;
  late final String initialYearId;

  @override
  void initState() {
    super.initState();
    final student = context.read<AuthBloc>().state.profileModel?.student;
    universityController.text = student?.universityId ?? '';
    collegeController.text = student?.collegeId ?? '';
    departmentController.text = student?.departmentId ?? '';
    yearController.text = student?.collegeYearId ?? '';

    initialUniversityId = student?.universityId ?? '';
    initialCollegeId = student?.collegeId ?? '';
    initialDepartmentId = student?.departmentId ?? '';
    initialYearId = student?.collegeYearId ?? '';

    if (widget.isForChangeYear) {
      BlocProvider.of<AuthBloc>(
        context,
      ).add(GetAcademicYearsEvent(collegeId: collegeController.text));
    } else {
      BlocProvider.of<AuthBloc>(context).add(GetUniversitiesEvent());
    }
  }

  final _formKey = GlobalKey<FormState>();

  bool get _didChangeAnything {
    return universityController.text != initialUniversityId ||
        collegeController.text != initialCollegeId ||
        departmentController.text != initialDepartmentId ||
        yearController.text != initialYearId;
  }

  bool _hasEmptyRequiredFields() {
    /// when changing only year
    if (widget.isForChangeYear) {
      return yearController.text.trim().isEmpty;
    }

    /// full university change
    return universityController.text.trim().isEmpty ||
        collegeController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: widget.isForChangeYear ? "تغيير السنة" : "تغيير الجامعة",
          onBackTap: () {
            context.pop();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.isForChangeYear) ...{
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return !state.getUniversities.isSuccess
                            ? Center(child: CoursatyAppLoader())
                            : CoursatyDropdown<String>(
                                label: 'الجامعة',
                                hint: 'الجامعة',
                                value: universityController.text.isEmpty
                                    ? null
                                    : universityController.text,
                                onChanged: (item) {
                                  if (item == null) return;
                                  universityController.text = item;
                                  collegeController.text = '';
                                  departmentController.text = '';
                                  yearController.text = '';
                                  BlocProvider.of<AuthBloc>(
                                    context,
                                  ).add(GetCollegesEvent(universityId: item));
                                },
                                validator: _requiredValidator,
                                items:
                                    state.universitiesResponseModel
                                        ?.map(
                                          (item) => DropdownMenuItem<String>(
                                            value: item.id,
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
                              ? CoursatyAppLoader()
                              : CoursatyDropdown<String>(
                                  label: 'الكلية',
                                  hint: 'الكلية',
                                  value: collegeController.text.isEmpty
                                      ? null
                                      : collegeController.text,
                                  validator: _requiredValidator,
                                  onChanged: (item) {
                                    if (item == null) return;
                                    collegeController.text = item;
                                    departmentController.text = '';
                                    yearController.text = '';
                                    BlocProvider.of<AuthBloc>(
                                      context,
                                    ).add(GetDepartmentsEvent(collegeId: item));
                                    BlocProvider.of<AuthBloc>(context).add(
                                      GetAcademicYearsEvent(collegeId: item),
                                    );
                                  },
                                  items:
                                      state.collegesResponseModel?.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.id,
                                          child: Text(item.name ?? ''),
                                        );
                                      }).toList() ??
                                      [],
                                );
                        }
                      },
                    ),
                    15.verticalSpace,
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return state.getDepartments.isInit
                            ? SizedBox.shrink()
                            : !state.getDepartments.isSuccess
                            ? CoursatyAppLoader()
                            : state.departmentsResponseModel.isNullOrEmpty
                            ? SizedBox.shrink()
                            : CoursatyDropdown<String>(
                                label: 'القسم',
                                hint: 'القسم',
                                value: departmentController.text.isEmpty
                                    ? null
                                    : departmentController.text,
                                validator: _requiredValidator,
                                onChanged: (item) {
                                  if (item == null) return;
                                  departmentController.text = item;
                                  yearController.text = '';
                                },
                                items:
                                    state.departmentsResponseModel
                                        ?.map(
                                          (item) => DropdownMenuItem<String>(
                                            value: item.id,
                                            child: Text(item.name ?? ''),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              );
                      },
                    ),
                    15.verticalSpace,
                  },
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return state.getYears.isInit
                          ? SizedBox.shrink()
                          : !state.getYears.isSuccess
                          ? CoursatyAppLoader()
                          : CoursatyDropdown<String>(
                              label: 'السنة',
                              hint: 'السنة',
                              value: yearController.text.isEmpty
                                  ? null
                                  : yearController.text,
                              validator: _requiredValidator,
                              onChanged: (item) {
                                if (item == null) return;
                                yearController.text = item;
                              },
                              items:
                                  state.academicYearsResponseModel
                                      ?.map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item.id,
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
                  const SizedBox(height: 18),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (p, c) => p.updateStudent != c.updateStudent,
                    builder: (context, state) {
                      return state.updateStudent.isLoading
                          ? CoursatyAppLoader()
                          : InkWell(
                              onTap: () {
                                if (!_didChangeAnything) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "لم تقم بتغيير أي معلومات",
                                        style: GoogleFonts.cairo(),
                                      ),
                                    ),
                                  );

                                  return;
                                }
                                if (_formKey.currentState!.validate()) {
                                  /// extra protection
                                  if (_hasEmptyRequiredFields()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _requiredFieldsMessage(),
                                          style: GoogleFonts.cairo(),
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  BlocProvider.of<AuthBloc>(context).add(
                                    UpdateStudentEvent(
                                      params: UpdateStudentParams(
                                        name:
                                            GetIt.I<PrefsRepository>().name ??
                                            '',
                                        universityId: universityController.text,
                                        collegeId: collegeController.text,
                                        departmentId:
                                            departmentController.text.isEmpty
                                            ? null
                                            : departmentController.text,
                                        collegeYearId: yearController.text,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [AppColors.buttonShadow],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'حفظ',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(dynamic item) {
    if (item == null || item == '') {
      return "الحقل مطلوب";
    }
    return null;
  }

  String _requiredFieldsMessage() {
    if (widget.isForChangeYear) {
      return "يرجى اختيار السنة";
    }

    if (universityController.text.trim().isEmpty) {
      return "يرجى اختيار الجامعة";
    }

    if (collegeController.text.trim().isEmpty) {
      return "يرجى اختيار الكلية";
    }

    if (yearController.text.trim().isEmpty) {
      return "يرجى اختيار السنة";
    }

    return "يرجى تعبئة جميع الحقول المطلوبة";
  }
}
