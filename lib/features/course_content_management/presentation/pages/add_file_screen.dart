import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_file_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/widgets/custom_choose_file_button.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/common/helper/show_message.dart';
import '../../../../core/utils/extensions/build_context.dart';
import '../../../courses/presentation/widgets/course_free_checkbox.dart';
import '../bloc/course_content_management_bloc.dart';

class AddFileScreen extends StatefulWidget {
  const AddFileScreen({
    super.key,
    required this.lectureId,
    this.fileElement,
    required this.courseId,
  });

  final String lectureId;
  final String courseId;
  final FileElement? fileElement;

  @override
  State<AddFileScreen> createState() => _AddFileScreenState();
}

class _AddFileScreenState extends State<AddFileScreen> {
  final ValueNotifier<XFile?> chooseFile = ValueNotifier(null);

  late final TextEditingController name;
  late final TextEditingController sortOrder;
  late final TextEditingController size;

  late final ValueNotifier<bool> isFree;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.fileElement?.fileName ?? '');
    sortOrder = TextEditingController(
      text: (widget.fileElement?.sortOrder ?? '').toString(),
    );
    size = TextEditingController();
    isFree = ValueNotifier(widget.fileElement?.isFree ?? false);
  }

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void dispose() {
    name.dispose();
    sortOrder.dispose();
    isFree.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: widget.fileElement != null ? "تعديل الملف" : "إضافة ملف",
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      CoursatyTextField(
                        label: 'اسم الملف',
                        validator: _requiredValidator,
                        controller: name,
                      ),
                      15.verticalSpace,
                      CoursatyTextField(
                        label: 'ترتيب الملف (اختياري)',
                        minLines: 1,
                        controller: sortOrder,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      15.verticalSpace,
                      IsFreeCourseTile(
                        isFreeNotifier: isFree,
                        title: "الملف مجاني",
                        description:
                            "عند تفعيل هذا الخيار سيتمكن الطلاب من الوصول إلى الملف مجاناً",
                      ),
                      // if (widget.fileElement == null) ...{
                      10.verticalSpace,
                      CustomChooseFileButton(
                        title: "رفع ملف",
                        usedForImage: false,
                        usedForFile: true,
                        choosedFile: chooseFile,
                        choosedFileSize: size,
                      ),
                      // },
                    ],
                  ),
                ),
                BlocConsumer<
                  CourseContentManagementBloc,
                  CourseContentManagementState
                >(
                  listenWhen: (p, c) => p.upsertLecture != c.upsertLecture,
                  listener: (context, state) {
                    if (state.upsertLecture.isFailed) {
                      showMessage(state.errorMessage);
                    }
                    if (state.upsertLecture.isSuccess) {
                      context.pop();
                    }
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: state.upsertLecture.isLoading
                          ? CoursatyAppLoader()
                          : CoursatyPrimaryButton(
                              label: widget.fileElement == null
                                  ? 'إضافة'
                                  : "تعديل",
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (widget.fileElement == null &&
                                      chooseFile.value == null) {
                                    showMessage("رجاء قم باختيار ملف");
                                    return;
                                  }
                                  BlocProvider.of<CourseContentManagementBloc>(
                                    context,
                                  ).add(
                                    UpsertFileEvent(
                                      lectureId: widget.lectureId,
                                      file: chooseFile.value,
                                      courseId: widget.courseId,
                                      UpsertFileParams(
                                        fileName: name.text,
                                        fileId: widget.fileElement?.id,
                                        fileUrl: widget.fileElement?.fileUrl,
                                        lectureId: widget.lectureId,
                                        isFree: isFree.value,
                                        sortOrder: sortOrder.text.trim().isEmpty
                                            ? null
                                            : sortOrder.text,
                                        size: size.text.trim().isEmpty
                                            ? null
                                            : size.text,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                    );
                  },
                ),
              ],
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
}
