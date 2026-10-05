import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart'
    hide Option;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/widgets/coursaty_button.dart';
import '../../../../app/widgets/coursaty_text_field.dart';
import '../../../../app/widgets/custom_choose_file_button.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/helper/show_message.dart';
import '../../../../core/utils/extensions/build_context.dart';
import '../../domain/usecases/upsert_question_usecase.dart';
import '../bloc/course_content_management_bloc.dart';

class UpsertQuestionPage extends StatefulWidget {
  const UpsertQuestionPage({
    super.key,
    required this.lectureId,
    required this.courseId,
    this.question,
  });

  final String lectureId;
  final String courseId;
  final QuestionModel? question;

  @override
  State<UpsertQuestionPage> createState() => _UpsertQuestionPageState();
}

class _UpsertQuestionPageState extends State<UpsertQuestionPage> {
  final GlobalKey<FormState> formKey = GlobalKey();

  late final TextEditingController questionText;
  late final TextEditingController explanation;
  late final TextEditingController sortOrder;

  final ValueNotifier<XFile?> selectedImage = ValueNotifier(null);

  late final List<OptionFormModel> options;

  @override
  void initState() {
    super.initState();

    questionText = TextEditingController(
      text: widget.question?.questionText ?? '',
    );

    explanation = TextEditingController(
      text: widget.question?.explanation ?? '',
    );

    sortOrder = TextEditingController(
      text: (widget.question?.sortOrder ?? '').toString(),
    );

    options =
        widget.question?.options
            ?.map(
              (e) => OptionFormModel(
                textController: TextEditingController(text: e.optionText ?? ''),
                isCorrect: ValueNotifier(e.isCorrect ?? false),
              ),
            )
            .toList() ??
        List.generate(
          4,
          (_) => OptionFormModel(
            textController: TextEditingController(),
            isCorrect: ValueNotifier(false),
          ),
        );
  }

  @override
  void dispose() {
    questionText.dispose();
    explanation.dispose();

    selectedImage.dispose();
    sortOrder.dispose();

    for (final option in options) {
      option.textController.dispose();
      option.isCorrect.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: widget.question == null ? "إضافة سؤال" : "تعديل السؤال",
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      CoursatyTextField(
                        label: 'نص السؤال',
                        controller: questionText,
                        minLines: 3,
                        validator: _requiredValidator,
                      ),

                      16.verticalSpace,

                      CoursatyTextField(
                        label: 'شرح الإجابة (اختياري)',
                        controller: explanation,
                        minLines: 3,
                      ),

                      16.verticalSpace,

                      CoursatyTextField(
                        label: 'ترتيب السؤال (اختياري)',
                        controller: sortOrder,
                        minLines: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      16.verticalSpace,

                      CustomChooseFileButton(
                        title: widget.question?.imageUrl != null
                            ? "تغيير صورة السؤال (اختياري)"
                            : "رفع صورة السؤال (اختياري)",
                        usedForImage: true,
                        usedForFile: false,
                        choosedFile: selectedImage,
                      ),

                      24.verticalSpace,

                      Text(
                        "الخيارات",
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      16.verticalSpace,

                      ...List.generate(options.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _OptionItem(
                            index: index,
                            option: options[index],
                          ),
                        );
                      }),
                    ],
                  ),
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
                    Navigator.pop(context);
                    if (widget.question != null) {
                      if (context.canPop()) {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: state.upsertLecture.isLoading
                        ? CoursatyAppLoader()
                        : CoursatyPrimaryButton(
                            label: widget.question == null ? 'إضافة' : 'تعديل',
                            onPressed: _submit,
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    options.removeWhere((item) => item.textController.text.trim().isEmpty);
    int hasCorrectAnswer = 0;
    for (int i = 0; i < options.length; i++) {
      if (options[i].isCorrect.value) {
        hasCorrectAnswer++;
      }
    }

    if (hasCorrectAnswer != 1) {
      showMessage("يجب أن يكون هناك إجابة صحيحة واحدة فقط");
      return;
    }
    bool hasEmptyOption = false;
    for (int i = 0; i < options.length; i++) {
      hasEmptyOption |= options[i].textController.text.trim().isEmpty;
    }

    if (hasEmptyOption) {
      showMessage("جميع الخيارات مطلوبة");
      return;
    }

    final mappedOptions = options
        .map(
          (e) => Option(
            optionText: e.textController.text.trim(),
            isCorrect: e.isCorrect.value,
            sortOrder: options.indexOf(e) + 1,
          ),
        )
        .toList();

    final sort = sortOrder.text.trim();
    BlocProvider.of<CourseContentManagementBloc>(context).add(
      UpsertQuestionEvent(
        UpsertQuestionParams(
          lectureId: widget.lectureId,
          questionId: widget.question?.id,
          sortOrder: int.tryParse(sort),
          questionText: questionText.text.trim().isEmpty
              ? null
              : questionText.text.trim(),
          explanation: explanation.text.trim().isEmpty
              ? null
              : explanation.text.trim(),
          imageUrl: widget.question?.imageUrl,
          options: mappedOptions,
        ),
        file: selectedImage.value,
        lectureId: widget.lectureId,
        courseId: widget.courseId,
      ),
    );
  }

  String? _requiredValidator(dynamic value) {
    if (value == null) {
      return "الحقل مطلوب";
    }

    if (value is String && value.trim().isEmpty) {
      return "الحقل مطلوب";
    }

    return null;
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem({required this.index, required this.option});

  final int index;
  final OptionFormModel option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          CoursatyTextField(
            label: "الخيار ${index + 1}",
            controller: option.textController,
            validator: (value) {
              if (index <= 1 && (value == null || value.trim().isEmpty)) {
                return "الخيار مطلوب";
              }

              return null;
            },
          ),

          10.verticalSpace,

          ValueListenableBuilder(
            valueListenable: option.isCorrect,
            builder: (_, value, __) {
              return CheckboxListTile(
                value: value,
                contentPadding: EdgeInsets.zero,
                title: const Text("إجابة صحيحة"),
                onChanged: (newValue) {
                  option.isCorrect.value = newValue ?? false;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class OptionFormModel {
  final TextEditingController textController;
  final ValueNotifier<bool> isCorrect;

  OptionFormModel({required this.textController, required this.isCorrect});
}
