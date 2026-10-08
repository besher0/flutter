import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/create_guest_account_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/coursaty_button.dart';
import '../../../../app/widgets/coursaty_dropdown.dart';
import '../../../../app/widgets/logout_confirmation_dialog.dart';
import '../../../../core/common/helper/show_message.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/storage/prefs_repository.dart';

class CreateGuestScreen extends StatefulWidget {
  const CreateGuestScreen({
    super.key,
    this.forEdit = false,
    this.forYearOnly = false,
  });

  final bool forEdit;
  final bool forYearOnly;

  @override
  State<CreateGuestScreen> createState() => _CreateGuestScreenState();
}

class _CreateGuestScreenState extends State<CreateGuestScreen> {
  final TextEditingController universityController = TextEditingController();

  final TextEditingController collegeController = TextEditingController();

  final TextEditingController departmentController = TextEditingController();

  final TextEditingController yearController = TextEditingController();

  final prefs = GetIt.I<PrefsRepository>();

  final GlobalKey<FormState> _formKey = GlobalKey();

  /// initial values
  late final String initialUniversityId;
  late final String initialCollegeId;
  late final String initialDepartmentId;
  late final String initialYearId;

  @override
  void initState() {
    super.initState();

    if (widget.forEdit) {
      universityController.text = prefs.universityId ?? '';
      collegeController.text = prefs.collegeId ?? '';
      departmentController.text = prefs.departmentId ?? '';
      yearController.text = prefs.yearCollegeId ?? '';
      BlocProvider.of<AuthBloc>(context).add(GetUniversitiesEvent());
      BlocProvider.of<AuthBloc>(
        context,
      ).add(GetCollegesEvent(universityId: universityController.text));
      BlocProvider.of<AuthBloc>(
        context,
      ).add(GetDepartmentsEvent(collegeId: collegeController.text));
    }

    initialUniversityId = prefs.universityId ?? '';
    initialCollegeId = prefs.collegeId ?? '';
    initialDepartmentId = prefs.departmentId ?? '';
    initialYearId = prefs.yearCollegeId ?? '';
    if (initialCollegeId != '') {
      BlocProvider.of<AuthBloc>(
        context,
      ).add(GetAcademicYearsEvent(collegeId: initialCollegeId));
    }
  }

  bool get _didChangeAnything {
    return universityController.text != initialUniversityId ||
        collegeController.text != initialCollegeId ||
        departmentController.text != initialDepartmentId ||
        yearController.text != initialYearId;
  }

  bool _hasEmptyRequiredFields() {
    return universityController.text.trim().isEmpty ||
        collegeController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty;
  }

  String _requiredFieldsMessage() {
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

  @override
  void dispose() {
    universityController.dispose();
    collegeController.dispose();
    departmentController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> makeOnBoardingSeen() {
    return prefs.setOnBoardingSeen(true);
  }

  Future<void> markUserAsGuest() {
    return GetIt.I<PrefsRepository>().setIsGuest(true);
  }

  Future<void> _guestSuccess(BuildContext context) async {
    if (widget.forEdit) {
      await signOut(context, clearUser: false);
    }

    await makeOnBoardingSeen();
    await markUserAsGuest();

    if (!widget.forEdit) {
      if (context.mounted) {
        context.go(GRouter.config.applicationRoutes.home);
      }
    }
  }

  String? _requiredValidator(dynamic item) {
    if (item == null || item == '') {
      return "الحقل مطلوب";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: "المتابعة كزائر",
        onBackTap: () => context.pop(),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 40),

              if (!widget.forYearOnly) ...{
                /// university
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

                            validator: _requiredValidator,
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

                /// colleges
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.getColleges.isInit) {
                      return const SizedBox.shrink();
                    }

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

                              BlocProvider.of<AuthBloc>(
                                context,
                              ).add(GetAcademicYearsEvent(collegeId: item));
                            },

                            items:
                                state.collegesResponseModel
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

                /// departments
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.getDepartments.isInit) {
                      return const SizedBox.shrink();
                    }

                    if (!state.getDepartments.isSuccess) {
                      return CoursatyAppLoader();
                    }

                    if (state.departmentsResponseModel == null ||
                        state.departmentsResponseModel!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return CoursatyDropdown<String>(
                      label: 'القسم',
                      hint: 'القسم',

                      value: departmentController.text.isEmpty
                          ? null
                          : departmentController.text,

                      validator: _requiredValidator,

                      onChanged: (item) {
                        if (item == null) return;

                        departmentController.text = item;
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

              /// years
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.getYears.isInit) {
                    return SizedBox.shrink();
                  }

                  return !state.getYears.isSuccess
                      ? CoursatyAppLoader()
                      : CoursatyDropdown<AcademicYearsResponseModel>(
                          label: 'السنة',
                          hint: 'السنة',

                          value: state.academicYearsResponseModel
                              ?.where((e) => e.id == yearController.text)
                              .firstOrNull,

                          validator: _requiredValidator,

                          onChanged: (item) {
                            if (item == null) return;

                            yearController.text = item.id ?? '';
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

              const SizedBox(height: 24),

              BlocConsumer<AuthBloc, AuthState>(
                listenWhen: (p, c) => p.getOrCreateGuest != c.getOrCreateGuest,

                buildWhen: (p, c) => p.getOrCreateGuest != c.getOrCreateGuest,

                listener: (context, state) {
                  if (state.getOrCreateGuest.isFailed) {
                    showMessage(state.errorMessage);
                  }

                  if (state.getOrCreateGuest.isSuccess) {
                    _guestSuccess(context);
                  }
                },

                builder: (context, state) {
                  return state.getOrCreateGuest.isLoading
                      ? CoursatyAppLoader()
                      : CoursatyPrimaryButton(
                          label: 'المتابعة',

                          onPressed: () {
                            FocusScope.of(context).unfocus();

                            final isValid =
                                _formKey.currentState?.validate() ?? false;

                            if (!isValid) {
                              return;
                            }

                            /// extra protection
                            if (_hasEmptyRequiredFields()) {
                              showMessage(_requiredFieldsMessage());
                              return;
                            }

                            /// no changes in edit mode
                            if (widget.forEdit && !_didChangeAnything) {
                              showMessage("لم تقم بتغيير أي معلومات");
                              return;
                            }

                            BlocProvider.of<AuthBloc>(context).add(
                              CreateGuestEvent(
                                params: CreateGuestAccountParams(
                                  universityId: universityController.text,

                                  collegeId: collegeController.text,

                                  departmentId: departmentController.text,

                                  yearCollegeId: yearController.text,
                                ),
                              ),
                            );
                          },
                        );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
