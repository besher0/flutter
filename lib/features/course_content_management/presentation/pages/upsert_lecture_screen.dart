import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_lecture_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddOrUpdateLectureScreen extends StatefulWidget {
  const AddOrUpdateLectureScreen({
    super.key,
    required this.courseId,
    this.lecture,
  });

  final String courseId;
  final Lecture? lecture;

  bool get isEditMode => lecture != null;

  @override
  State<AddOrUpdateLectureScreen> createState() =>
      _AddOrUpdateLectureScreenState();
}

class _AddOrUpdateLectureScreenState extends State<AddOrUpdateLectureScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;

  late final TextEditingController _descriptionController;

  late final TextEditingController _sortOrderController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.lecture?.title ?? '');

    _descriptionController = TextEditingController(
      text: widget.lecture?.description ?? '',
    );

    _sortOrderController = TextEditingController(
      text: widget.lecture?.sortOrder.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();

    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();

      final description = _descriptionController.text.trim();

      final String order = _sortOrderController.text.trim();
      final sortOrder = order.isEmpty ? null : int.parse(order);

      if (widget.isEditMode) {
        BlocProvider.of<CourseContentManagementBloc>(context).add(
          UpsertLectureEvent(
            UpsertLectureParams(
              lectureId: widget.lecture!.id!,
              title: title,
              description: description.isEmpty ? null : description,
              sortOrder: sortOrder,
              courseId: widget.courseId,
            ),
          ),
        );
      } else {
        BlocProvider.of<CourseContentManagementBloc>(context).add(
          UpsertLectureEvent(
            UpsertLectureParams(
              title: title,
              description: description.isEmpty ? null : description,
              sortOrder: sortOrder,
              courseId: widget.courseId,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        appBar: TitleAppBar(
          title: widget.isEditMode ? 'تعديل المحاضرة' : 'إضافة محاضرة',
          onBackTap: () {
            context.pop();
          },
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  CoursatyTextField(
                    label: 'عنوان المحاضرة',
                    hint: 'عنوان المحاضرة',
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    validator: _requiredValidator,
                  ),

                  const SizedBox(height: 18),

                  CoursatyTextField(
                    label: 'وصف المحاضرة (اختياري)',
                    hint: 'وصف المحاضرة (اختياري)',
                    controller: _descriptionController,
                    textInputAction: TextInputAction.newline,
                    minLines: 4,
                  ),

                  const SizedBox(height: 18),

                  CoursatyTextField(
                    label: 'ترتيب المحاضرة (اختياري)',
                    hint: 'ترتيب المحاضرة (اختياري)',
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 40),

                  BlocConsumer<
                    CourseContentManagementBloc,
                    CourseContentManagementState
                  >(
                    listenWhen: (p, c) => p.upsertCourse != c.upsertCourse,
                    buildWhen: (p, c) => p.upsertCourse != c.upsertCourse,
                    listener: (context, state) {
                      if (state.upsertCourse.isFailed) {
                        showMessage(state.errorMessage);
                      }

                      if (state.upsertCourse.isSuccess) {
                        showMessage(
                          widget.isEditMode
                              ? 'تم تعديل المحاضرة بنجاح'
                              : 'تمت إضافة المحاضرة بنجاح',
                        );
                        context.pop();
                        BlocProvider.of<CoursesBloc>(context).add(
                          GetTeacherCourseDetailsEvent(
                            courseId: widget.courseId,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return state.upsertCourse.isLoading
                          ? CoursatyAppLoader()
                          : CoursatyPrimaryButton(
                              label: widget.isEditMode
                                  ? 'حفظ التعديلات'
                                  : 'إضافة المحاضرة',
                              onPressed: _submit,
                            );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
