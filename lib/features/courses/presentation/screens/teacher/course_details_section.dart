import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/date_time.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/widgets/coursaty_button.dart';
import '../../../../../app/widgets/coursaty_dropdown.dart';
import '../../../../../app/widgets/coursaty_text_field.dart';
import '../../../../../app/widgets/custom_choose_file_button.dart';
import '../../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../home/presentation/bloc/home_bloc.dart';
import '../../../data/model/teacher_course_details_model.dart';
import '../../widgets/course_free_checkbox.dart';

class CourseDetailsSection extends StatefulWidget {
  const CourseDetailsSection({
    super.key,
    this.courseDetailsModel,
    this.subjectId,
  });

  final TeacherCourseDetailsResponseModel? courseDetailsModel;
  final String? subjectId;

  @override
  State<CourseDetailsSection> createState() => _CourseDetailsSectionState();
}

class _CourseDetailsSectionState extends State<CourseDetailsSection> {
  // final TextEditingController universityController = TextEditingController();
  //
  // final TextEditingController collegeController = TextEditingController();
  //
  // final TextEditingController departmentController = TextEditingController();

  final TextEditingController categoryController = TextEditingController();

  // final TextEditingController yearController = TextEditingController();
  final TextEditingController seasonController = TextEditingController();
  final TextEditingController expiredController = TextEditingController();

  late final TextEditingController courseName,
      courseDescription,
      courseTelegram,
      courseDiscussionGroup,
      courseYoutube,
      courseInstagram,
      price,
      priceAfterDiscount;

  // duration;

  late final ValueNotifier<XFile?> chooseFile;
  late final ValueNotifier<bool> isFreeNotifier;

  bool isFieldsInitialized = false;
  DateTime? expiredDate;
  String? categoryId;

  @override
  void initState() {
    super.initState();
    chooseFile = ValueNotifier(null);
    isFreeNotifier = ValueNotifier(false);
    courseName = TextEditingController();
    courseDescription = TextEditingController();
    courseTelegram = TextEditingController();
    courseDiscussionGroup = TextEditingController();
    courseYoutube = TextEditingController();
    courseInstagram = TextEditingController();
    price = TextEditingController();
    priceAfterDiscount = TextEditingController();
    // duration = TextEditingController();
    BlocProvider.of<CoursesBloc>(context).add(GetCoursesCategoriesEvent());
    BlocProvider.of<CourseContentManagementBloc>(
      context,
    ).add(GetAllSeasonsEvent());
    if (widget.courseDetailsModel != null) {
      initializeControllers(widget.courseDetailsModel!);
    }
  }

  @override
  void dispose() {
    courseName.dispose();
    courseDescription.dispose();
    courseTelegram.dispose();
    courseDiscussionGroup.dispose();
    courseYoutube.dispose();
    // duration.dispose();
    priceAfterDiscount.dispose();
    courseInstagram.dispose();
    price.dispose();
    chooseFile.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Widget content = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BlocBuilder<AuthBloc, AuthState>(
          //   builder: (context, state) {
          //     return !state.getUniversities.isSuccess
          //         ? Center(child: CoursatyAppLoader())
          //         : CoursatyDropdown<String>(
          //             label: 'الجامعة',
          //             hint: 'الجامعة',
          //             value: universityController.text.isEmpty
          //                 ? null
          //                 : universityController.text,
          //             onChanged: (item) {
          //               if (item == null) return;
          //               universityController.text = item;
          //               collegeController.text = '';
          //               departmentController.text = '';
          //               yearController.text = '';
          //               BlocProvider.of<AuthBloc>(
          //                 context,
          //               ).add(GetCollegesEvent(universityId: item));
          //             },
          //             validator: _requiredValidator,
          //             items:
          //                 state.universitiesResponseModel
          //                     ?.map(
          //                       (item) => DropdownMenuItem<String>(
          //                         value: item.id,
          //                         child: Text(item.name ?? ''),
          //                       ),
          //                     )
          //                     .toList() ??
          //                 [],
          //           );
          //   },
          // ),
          // BlocBuilder<AuthBloc, AuthState>(
          //   builder: (context, state) {
          //     if (state.getColleges.isInit) {
          //       return SizedBox.shrink();
          //     } else {
          //       return !state.getColleges.isSuccess
          //           ? CoursatyAppLoader()
          //           : Column(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 15.verticalSpace,
          //                 CoursatyDropdown<String>(
          //                   label: 'الكلية',
          //                   hint: 'الكلية',
          //                   value: collegeController.text.isEmpty
          //                       ? null
          //                       : collegeController.text,
          //                   validator: _requiredValidator,
          //                   onChanged: (item) {
          //                     if (item == null) return;
          //                     collegeController.text = item;
          //                     departmentController.text = '';
          //                     yearController.text = '';
          //                     BlocProvider.of<AuthBloc>(
          //                       context,
          //                     ).add(GetDepartmentsEvent(collegeId: item));
          //                     BlocProvider.of<AuthBloc>(
          //                       context,
          //                     ).add(GetAcademicYearsEvent(collegeId: item));
          //                   },
          //                   items:
          //                       state.collegesResponseModel?.map((item) {
          //                         return DropdownMenuItem<String>(
          //                           value: item.id,
          //                           child: Text(item.name ?? ''),
          //                         );
          //                       }).toList() ??
          //                       [],
          //                 ),
          //               ],
          //             );
          //     }
          //   },
          // ),
          // BlocBuilder<AuthBloc, AuthState>(
          //   builder: (context, state) {
          //     return state.getDepartments.isInit
          //         ? SizedBox.shrink()
          //         : !state.getDepartments.isSuccess
          //         ? CoursatyAppLoader()
          //         : Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               15.verticalSpace,
          //               CoursatyDropdown<String>(
          //                 label: 'القسم',
          //                 hint: 'القسم',
          //                 value: departmentController.text.isEmpty
          //                     ? null
          //                     : departmentController.text,
          //                 validator: _requiredValidator,
          //                 onChanged: (item) {
          //                   if (item == null) return;
          //                   departmentController.text = item;
          //                   yearController.text = '';
          //                 },
          //                 items:
          //                     state.departmentsResponseModel
          //                         ?.map(
          //                           (item) => DropdownMenuItem<String>(
          //                             value: item.id,
          //                             child: Text(item.name ?? ''),
          //                           ),
          //                         )
          //                         .toList() ??
          //                     [],
          //               ),
          //             ],
          //           );
          //   },
          // ),
          // BlocBuilder<AuthBloc, AuthState>(
          //   builder: (context, state) {
          //     return state.getYears.isInit
          //         ? SizedBox.shrink()
          //         : !state.getYears.isSuccess
          //         ? CoursatyAppLoader()
          //         : Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               CoursatyDropdown<String>(
          //                 label: 'السنة',
          //                 hint: 'السنة',
          //                 value: yearController.text.isEmpty
          //                     ? null
          //                     : yearController.text,
          //                 validator: _requiredValidator,
          //                 onChanged: (item) {
          //                   if (item == null) return;
          //                   yearController.text = item;
          //                 },
          //                 items:
          //                     state.academicYearsResponseModel
          //                         ?.map(
          //                           (item) => DropdownMenuItem<String>(
          //                             value: item.id,
          //                             child: Text(
          //                               item.academicYear?.yearName ?? '',
          //                             ),
          //                           ),
          //                         )
          //                         .toList() ??
          //                     [],
          //               ),
          //               15.verticalSpace,
          //             ],
          //           );
          //   },
          // ),
          // 15.verticalSpace,
          BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              return state.getCoursesCategories.isInit
                  ? SizedBox.shrink()
                  : !state.getCoursesCategories.isSuccess
                  ? CoursatyAppLoader()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CoursatyDropdown<String>(
                          label: 'فئة الكورس',
                          hint: 'فئة الكورس',
                          enabled: widget.courseDetailsModel == null,
                          value: categoryController.text.isEmpty
                              ? null
                              : categoryController.text,
                          validator: _requiredValidator,
                          onChanged: (item) {
                            if (item == null) return;
                            categoryController.text = item;
                          },
                          items: state.coursesCategories
                              .getRange(2, state.coursesCategories.length)
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text(item.name ?? ''),
                                ),
                              )
                              .toList(),
                        ),
                        15.verticalSpace,
                      ],
                    );
            },
          ),
          // BlocBuilder<
          //   CourseContentManagementBloc,
          //   CourseContentManagementState
          // >(
          //   builder: (context, state) {
          //     return !state.getAllSeasons.isSuccess
          //         ? Center(child: CoursatyAppLoader())
          //         : Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               CoursatyDropdown<String>(
          //                 label: 'الفصل',
          //                 hint: 'الفصل',
          //                 value: seasonController.text.isEmpty
          //                     ? null
          //                     : seasonController.text,
          //                 onChanged: (item) {
          //                   if (item == null) return;
          //                   seasonController.text = item;
          //                 },
          //                 validator: _requiredValidator,
          //                 items:
          //                     state.seasons
          //                         .map(
          //                           (item) => DropdownMenuItem<String>(
          //                             value: item.id,
          //                             child: Text(item.seasonName ?? ''),
          //                           ),
          //                         )
          //                         .toList() ??
          //                     [],
          //               ),
          //               15.verticalSpace,
          //             ],
          //           );
          //   },
          // ),
          if (widget.courseDetailsModel?.course?.imageUrl != null) ...{
            CachedNetworkImage(
              imageUrl: widget.courseDetailsModel!.course!.imageUrl!,
              height: 120,
              width: 1.sw,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.black),
            ),
          },
          CoursatyTextField(
            label: 'اسم الكورس',
            hint: 'اسم الكورس',
            validator: _requiredValidator,
            controller: courseName,
            readOnly: widget.courseDetailsModel != null,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'عن الكورس',
            hint: 'عن الكورس',
            validator: _requiredValidator,
            minLines: 4,
            controller: courseDescription,
            readOnly: widget.courseDetailsModel != null,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'سعر الكورس',
            hint: 'سعر الكورس',
            validator: _numberValidator,
            controller: price,
            readOnly: widget.courseDetailsModel != null,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'السعر بعد الخصم (اختياري)',
            hint: 'السعر بعد الخصم (اختياري)',
            controller: priceAfterDiscount,
            readOnly: widget.courseDetailsModel != null,
          ),
          10.verticalSpace,
          // CoursatyTextField(
          //   label: 'مدة للكورس',
          //   hint: 'مدة للكورس',
          //   validator: _floatNumberValidator,
          //   controller: duration,
          // ),
          // 10.verticalSpace,
          IsFreeCourseTile(
            isFreeNotifier: isFreeNotifier,
            enabled: widget.courseDetailsModel == null,
          ),
          10.verticalSpace,
          if (widget.courseDetailsModel?.course?.imageUrl == null)
            CustomChooseFileButton(
              usedForImage: true,
              usedForFile: false,
              title: widget.courseDetailsModel?.course?.imageUrl != null
                  ? "تعديل صورة الكورس"
                  : "رفع صورة للكورس",
              choosedFile: chooseFile,
            ),
          CoursatyTextField(
            label: 'رابط التلغرام (اختياري)',
            hint: 'https://t.me/...',
            controller: courseTelegram,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: 'رابط مجموعة النقاش (اختياري)',
            hint: 'https://t.me/...',
            controller: courseDiscussionGroup,
          ),
          10.verticalSpace,
          CoursatyTextField(
            label: ' رابط فيديو تعريفي(يوتيوب) (اختياري)',
            hint: 'رابط فيديو تعريفي(يوتيوب) (اختياري)',
            controller: courseYoutube,
            readOnly: widget.courseDetailsModel != null,
          ),
          10.verticalSpace,
          // CoursatyTextField(
          //   label: 'رابط صفحة الانستغرام',
          //   hint: 'رابط صفحة الانستغرام',
          //   controller: courseYoutube,
          // ),
          // 10.verticalSpace,
          CoursatyTextField(
            label: 'تاريخ انتهاء الكورس (اختياري)',
            hint: 'تاريخ انتهاء الكورس (اختياري)',
            controller: expiredController,
            // validator: _requiredValidator,
            readOnly: widget.courseDetailsModel != null,
            onTap: () async {
              // if (widget.courseDetailsModel != null) {
              //   showMessage(
              //     "لايمكن تعديل تاريخ الانتهاء , إذا قمت بإدخال قيمة خاطئة تواصل مع الأدمن",
              //   );
              //   return;
              // }
              if (widget.courseDetailsModel != null) {
                return;
              }
              expiredDate = await HelperFunctions.pickDate(context: context);
              expiredController.text = expiredDate?.dmy ?? '';
            },
          ),
          const SizedBox(height: 16),
          BlocConsumer<
            CourseContentManagementBloc,
            CourseContentManagementState
          >(
            buildWhen: (p, c) => p.createCourse != c.createCourse,
            listenWhen: (p, c) => p.createCourse != c.createCourse,
            listener: (context, state) {
              if (state.createCourse.isFailed) {
                showMessage(state.errorMessage);
              }
              if (state.createCourse.isSuccess) {
                context.go(GRouter.config.applicationRoutes.home);
                BlocProvider.of<HomeBloc>(
                  context,
                ).add(ChangeCurrentScreenEvent(newPage: 1));
                BlocProvider.of<CoursesBloc>(
                  context,
                ).add(GetTeacherCourses(getActive: true, reset: true));
                BlocProvider.of<CoursesBloc>(
                  context,
                ).add(GetTeacherCourses(getActive: false, reset: true));
              }
            },
            builder: (context, state) {
              return state.createCourse.isLoading
                  ? CoursatyAppLoader()
                  : CoursatyPrimaryButton(
                      label: widget.courseDetailsModel != null
                          ? 'تعديل'
                          : "إضافة",
                      onPressed: () {
                        if (widget.courseDetailsModel != null &&
                            expiredDate != null &&
                            !DateTime.now()
                                .difference(expiredDate!)
                                .isNegative) {
                          showMessage(
                            "انتهت مدة الكورس , لم يعد بالإمكان التعديل عليه",
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          if (widget.courseDetailsModel == null &&
                              chooseFile.value == null) {
                            showMessage("الرجاء إرفاق صورة للكورس");
                            return;
                          }

                          // if (expiredDate == null) {
                          //   showMessage("الرجاء إرفاق تاريخ انتهاء الكورس");
                          //   return;
                          // }
                          int priceBefore = int.parse(price.text);
                          int priceAfter = priceAfterDiscount.text.isEmpty
                              ? priceBefore
                              : int.parse(priceAfterDiscount.text);
                          double percent = priceBefore == 0
                              ? 0
                              : (((priceBefore - priceAfter) * 100) /
                                    priceBefore);
                          if (percent < 0 || percent > 100) {
                            showMessage("السعر قبل الخصم وبعده غير متوافقان");
                            return;
                          }
                          if (isFreeNotifier.value &&
                              (priceBefore != 0 || priceAfter != 0)) {
                            showMessage(
                              "الكورس مجاني , يجب ان يكون سعره مساو للصفر قبل وبعد الخصم",
                            );
                            return;
                          }
                          // if (!isFreeNotifier.value && priceBefore == 0) {
                          //   showMessage("يجب أن يكون للكورس سعر أكبر من 0");
                          //   return;
                          // }
                          BlocProvider.of<CourseContentManagementBloc>(
                            context,
                          ).add(
                            UpsertCourseEvent(
                              image: chooseFile.value == null
                                  ? null
                                  : File(chooseFile.value!.path),
                              params: UpsertCourseParams(
                                name: courseName.text,
                                description: courseDescription.text,
                                subjectId:
                                    widget.subjectId ??
                                    widget
                                        .courseDetailsModel
                                        ?.details
                                        ?.subjectId ??
                                    'f1501fa6-6b10-48d8-84d5-e7f2006a7363',
                                categoryId: categoryController.text,
                                price: int.parse(price.text),
                                courseDiscountPercentage: percent,
                                // duration: double.parse(duration.text),
                                isFree: isFreeNotifier.value,
                                expiresAt: expiredDate,
                                // seasonId: seasonController.text,
                                // universityId: universityController.text,
                                // collegeId: collegeController.text,
                                // yearId: yearController.text,
                                // departmentId: departmentController.text.isEmpty
                                //     ? null
                                //     : departmentController.text,
                                telegramUrl: courseTelegram.text.trim().isEmpty
                                    ? null
                                    : courseTelegram.text.trim(),
                                discussionGroupUrl:
                                    courseDiscussionGroup.text.trim().isEmpty
                                    ? null
                                    : courseDiscussionGroup.text.trim(),
                                introVideoUrl: courseYoutube.text.trim().isEmpty
                                    ? null
                                    : courseYoutube.text,
                                instagramUrl: courseInstagram.text,
                                imageUrl:
                                    widget.courseDetailsModel?.course?.imageUrl,

                                courseId: widget.courseDetailsModel?.course?.id,
                              ),
                            ),
                          );
                        }
                      },
                    );
            },
          ),
          const SizedBox(height: 16),
          CoursatySecondaryButton(
            label: 'إلغاء',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (widget.courseDetailsModel == null) {
      return content;
    }
    return RefreshIndicator(
      onRefresh: () async {
        BlocProvider.of<CoursesBloc>(context).add(
          GetTeacherCourseDetailsEvent(
            courseId: widget.courseDetailsModel!.course!.id!,
          ),
        );
      },
      child: content,
    );
  }

  void initializeControllers(TeacherCourseDetailsResponseModel data) {
    if (isFieldsInitialized) return;
    isFieldsInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        categoryController.text = data.details?.categoryId ?? '';
        courseName.text = data.course?.name ?? '';
        courseDescription.text = data.details?.description ?? '';
        courseTelegram.text = data.course?.telegramUrl ?? '';
        courseDiscussionGroup.text = data.details?.discussionGroupUrl ?? '';
        courseYoutube.text = data.details?.introVideoUrl ?? '';
        // universityController.text = data.details?.universityId ?? '';
        // collegeController.text = data.details?.collegeId ?? '';
        // departmentController.text = data.details?.departmentId ?? '';
        // yearController.text = data.details?.yearId ?? '';
        seasonController.text = data.details?.seasonId ?? '';
        categoryId = data.details?.seasonId ?? '';
        // duration.text = ((data.details?.durationSeconds ?? 0) ~/ 3600)
        //     .toString();

        price.text = (data.course?.basePrice ?? '').toString();
        priceAfterDiscount.text = (data.course?.discountedPrice ?? '')
            .toString();
        isFreeNotifier.value = data.course?.isFree ?? false;
        expiredDate = data.details?.expiresAt;
        expiredController.text = expiredDate?.dmy ?? '';
      });
    });
  }

  String? _requiredValidator(dynamic item) {
    if (item == null) {
      return "الحقل مطلوب";
    }
    return null;
  }

  String? _numberValidator(dynamic item) {
    if (item == null) {
      return "الحقل مطلوب";
    }
    if (int.tryParse(item) == null || int.tryParse(item)! < 0) {
      return "الرجاء إدخال عدد موجب";
    }
    return null;
  }
}
