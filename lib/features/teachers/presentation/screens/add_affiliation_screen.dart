import 'package:coursaty_student_and_teacher/app/widgets/coursaty_dropdown.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/list_extensions.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/add_or_remove_affiliations_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAffiliationScreen extends StatefulWidget {
  const AddAffiliationScreen({super.key});

  @override
  State<AddAffiliationScreen> createState() => _AddAffiliationScreenState();
}

class _AddAffiliationScreenState extends State<AddAffiliationScreen> {
  final TextEditingController universityController = TextEditingController();

  final TextEditingController collegeController = TextEditingController();

  final TextEditingController departmentController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AuthBloc>(context).add(GetUniversitiesEvent());
  }

  @override
  void dispose() {
    universityController.dispose();
    collegeController.dispose();
    departmentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: "إضافة انتماء جامعي",
          onBackTap: () {
            context.pop();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// الجامعة
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return !state.getUniversities.isSuccess
                          ? Center(child: CoursatyAppLoader())
                          : CoursatyDropdown<String>(
                              label: 'الجامعة',
                              hint: 'اختر الجامعة',
                              value: universityController.text.isEmpty
                                  ? null
                                  : universityController.text,
                              validator: _requiredValidator,
                              onChanged: (item) {
                                if (item == null) {
                                  return;
                                }

                                universityController.text = item;

                                collegeController.clear();

                                departmentController.clear();

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

                  16.verticalSpace,

                  /// الكلية
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.getColleges.isInit) {
                        return const SizedBox.shrink();
                      }

                      return !state.getColleges.isSuccess
                          ? Center(child: CoursatyAppLoader())
                          : CoursatyDropdown<String>(
                              label: 'الكلية',
                              hint: 'اختر الكلية',
                              validator: _requiredValidator,
                              value: collegeController.text.isEmpty
                                  ? null
                                  : collegeController.text,
                              onChanged: (item) {
                                if (item == null) {
                                  return;
                                }

                                collegeController.text = item;

                                departmentController.clear();

                                BlocProvider.of<AuthBloc>(
                                  context,
                                ).add(GetDepartmentsEvent(collegeId: item));
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

                  16.verticalSpace,

                  /// القسم
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.getDepartments.isInit) {
                        return const SizedBox.shrink();
                      }

                      return !state.getDepartments.isSuccess
                          ? Center(child: CoursatyAppLoader())
                          : state.departmentsResponseModel.isNullOrEmpty
                          ? SizedBox.shrink()
                          : CoursatyDropdown<String>(
                              label: 'القسم',
                              hint: 'اختر القسم',
                              validator: _requiredValidator,
                              value: departmentController.text.isEmpty
                                  ? null
                                  : departmentController.text,
                              onChanged: (item) {
                                if (item == null) {
                                  return;
                                }

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

                  28.verticalSpace,

                  /// زر الحفظ
                  BlocConsumer<TeachersBloc, TeachersState>(
                    buildWhen: (p, c) =>
                        p.affiliationsStatus != c.affiliationsStatus,
                    listenWhen: (p, c) =>
                        p.affiliationsStatus != c.affiliationsStatus,
                    listener: (context, state) {
                      if (state.affiliationsStatus.isSuccess) {
                        context.pop();
                      }
                    },
                    builder: (context, state) {
                      return state.affiliationsStatus.isLoading
                          ? Center(child: CoursatyAppLoader())
                          : InkWell(
                              onTap: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                BlocProvider.of<TeachersBloc>(context).add(
                                  AddOrDeleteTeacherAffiliations(
                                    params: AddOrRemoveAffiliationsParams(
                                      universityId: universityController.text,
                                      collegeId: collegeController.text,
                                      departmentId:
                                          departmentController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : departmentController.text,
                                      isForDelete: false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [AppColors.buttonShadow],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'إضافة الانتماء',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(dynamic item) {
    if (item == null || item.toString().isEmpty) {
      return 'الحقل مطلوب';
    }

    return null;
  }
}
