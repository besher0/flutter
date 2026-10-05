import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/question_info_dialog.dart';
import 'package:coursaty_student_and_teacher/app/widgets/zoomable_image.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/security/secure_student_content.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/theme/app_colors.dart';

class McqQuestionsScreen extends StatefulWidget {
  const McqQuestionsScreen({
    super.key,
    required this.questions,
    required this.courseId,
    this.fromNetwork = true,
    this.onDelete,
    this.lectureDetailsModelFromDownload,
    this.onEdit,
  });

  final bool fromNetwork;
  final List<QuestionModel> questions;
  final String courseId;
  final Function(QuestionModel question)? onDelete, onEdit;
  final LectureDetailsModel? lectureDetailsModelFromDownload;

  @override
  State<McqQuestionsScreen> createState() => _McqQuestionsScreenState();
}

class _McqQuestionsScreenState extends State<McqQuestionsScreen> {
  final Map<String, String> _answers = {};
  List<QuestionModel> questions = [];

  /// questions that user checked
  final Set<String> _checkedQuestions = {};
  ScreenCaptureLease? _captureLease;

  void _checkAllAnswers() {
    setState(() {
      for (int groupIndex = 0; groupIndex < questions.length; groupIndex++) {
        final key = '$groupIndex-0';

        /// check only answered questions
        if (_answers.containsKey(key)) {
          _checkedQuestions.add(key);
        }
      }
    });
  }

  @override
  void initState() {
    questions = widget.questions;
    super.initState();
    _captureLease = StudentContentProtection.claim();
  }

  @override
  void dispose() {
    _captureLease?.release();
    super.dispose();
  }

  void _clearAllAnswers() {
    setState(() {
      _answers.clear();
      _checkedQuestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: 'الأتمتات',
        onBackTap: () {
          context.pop();
        },
      ),

      bottomNavigationBar: questions.isEmpty
          ? SizedBox.shrink()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(
                            Size.fromHeight(50),
                          ),
                        ),
                        onPressed: _checkAllAnswers,
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          'فحص جميع الإجابات',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    15.horizontalSpace,

                    Expanded(
                      child: OutlinedButton.icon(
                        style: ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(
                            Size.fromHeight(50),
                          ),
                        ),
                        onPressed: _clearAllAnswers,
                        icon: Icon(
                          Icons.refresh,
                          color: context.colorScheme.onSurface,
                        ),
                        label: Text(
                          'إعادة التعيين',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

      body: SafeArea(
        child: BlocBuilder<CoursesBloc, CoursesState>(
          buildWhen: (p, c) =>
              p.lectureDetailsModel.hashCode != c.lectureDetailsModel.hashCode,
          builder: (context, state) {
            questions = widget.lectureDetailsModelFromDownload != null
                ? (widget.lectureDetailsModelFromDownload!.questions ?? [])
                : state.lectureDetailsModel!.questions ?? [];
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: questions.length,
              itemBuilder: (_, groupIndex) {
                final question = questions[groupIndex];

                return _QuestionGroupCard(
                  courseId: widget.courseId,
                  fromNetwork: widget.fromNetwork,
                  group: _QuestionGroup(
                    title: "السؤال رقم ${groupIndex + 1}",
                    questions: [question],
                  ),
                  groupIndex: groupIndex,
                  selectedAnswers: _answers,
                  checkedQuestions: _checkedQuestions,
                  onDelete: widget.onDelete == null
                      ? null
                      : () {
                          widget.onDelete?.call(question);
                        },
                  onEdit: widget.onEdit == null
                      ? null
                      : () {
                          widget.onEdit?.call(question);
                        },
                  onChanged: (key, value) {
                    setState(() {
                      _answers[key] = value;
                    });
                  },
                  onCheckQuestion: (key) {
                    setState(() {
                      _checkedQuestions.add(key);
                    });
                  },
                  onResetQuestion: (key) {
                    setState(() {
                      _checkedQuestions.remove(key);
                      _answers.remove(key);
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _QuestionGroupCard extends StatelessWidget {
  const _QuestionGroupCard({
    required this.group,
    required this.groupIndex,
    required this.selectedAnswers,
    required this.checkedQuestions,
    required this.onChanged,
    required this.onCheckQuestion,
    required this.onResetQuestion,
    required this.courseId,
    required this.fromNetwork,
    this.onDelete,
    this.onEdit,
  });

  final bool fromNetwork;
  final String courseId;
  final _QuestionGroup group;
  final int groupIndex;

  final Map<String, String> selectedAnswers;

  final Set<String> checkedQuestions;

  final void Function(String, String) onChanged;

  final void Function(String key) onCheckQuestion;

  final void Function(String key) onResetQuestion;
  final void Function()? onDelete, onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            group.title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(height: 8),

          ...group.questions.asMap().entries.map((entry) {
            final qIndex = entry.key;
            final question = entry.value;

            final key = '$groupIndex-$qIndex';

            return _QuestionCard(
              question: question,
              courseId: courseId,
              selectedOption: selectedAnswers[key],
              isChecked: checkedQuestions.contains(key),
              onSelected: (v) => onChanged(key, v),
              onCheck: () => onCheckQuestion(key),
              onReset: () => onResetQuestion(key),
              onEdit: onEdit,
              onDelete: onDelete,
              fromNetwork: fromNetwork,
            );
          }),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedOption,
    required this.onSelected,
    required this.courseId,
    required this.isChecked,
    required this.onCheck,
    required this.onReset,
    required this.fromNetwork,
    this.onDelete,
    this.onEdit,
  });

  final QuestionModel question;

  final String? selectedOption;

  final bool isChecked;
  final bool fromNetwork;

  final VoidCallback onCheck;

  final VoidCallback onReset;
  final VoidCallback? onDelete, onEdit;

  final ValueChanged<String> onSelected;

  final String courseId;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  @override
  void initState() {
    super.initState();
    if (widget.question.imageUrl != null) {
      BlocProvider.of<DownloadingMediaBloc>(context).add(
        DownloadFileEvent(
          fileUrl: widget.question.imageUrl!,
          downloadUrl: widget.question.imageUrl!,
          fileType: 'image',
          courseId: widget.courseId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctOptionId = widget.question.options
        ?.firstWhere((e) => e.isCorrect == true)
        .id;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.question.questionText != null)
            Text(
              widget.question.questionText!,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (widget.question.imageUrl != null && widget.onEdit != null) ...[
            const SizedBox(height: 10),
            ZoomableImage(
              imageUrl: widget.question.imageUrl!,
              fromNetwork: widget.fromNetwork,
            ),
          ],
          if (widget.question.imageUrl != null && widget.onEdit == null) ...[
            const SizedBox(height: 8),

            BlocBuilder<DownloadingMediaBloc, DownloadingMediaState>(
              buildWhen: (p, c) {
                final url = widget.question.imageUrl!;
                return p.downloadingStatus[url] != c.downloadingStatus[url];
              },
              builder: (context, downloadState) {
                final url = widget.question.imageUrl!;

                final path = context
                    .read<MyDownloadsBloc>()
                    .state
                    .urlToFileReferences[url];

                return downloadState.downloadingStatus[url] == true
                    ? CoursatyAppLoader()
                    : path == null
                    ? IconButton(
                        onPressed: () {
                          BlocProvider.of<DownloadingMediaBloc>(context).add(
                            DownloadFileEvent(
                              fileUrl: url,
                              downloadUrl: url,
                              fileType: "image",
                              courseId: widget.courseId,
                            ),
                          );
                        },
                        icon: Icon(Icons.refresh),
                      )
                    : ZoomableImage(imageUrl: path, fromNetwork: false);
              },
            ),
          ],

          const SizedBox(height: 8),

          ...widget.question.options?.map((e) {
                final selected = widget.selectedOption == e.id;

                Color borderColor = AppColors.primaryLightBorder;

                Color textColor = Theme.of(context).colorScheme.onSurface;

                FontWeight fontWeight = FontWeight.w400;

                if (widget.isChecked) {
                  /// correct answer
                  if (e.id == correctOptionId) {
                    borderColor = Colors.green;
                    textColor = Colors.green;
                    fontWeight = FontWeight.w700;
                  }
                  /// wrong selected answer
                  else if (selected) {
                    borderColor = Colors.red;
                    textColor = Colors.red;
                    fontWeight = FontWeight.w700;
                  }
                } else if (selected) {
                  borderColor = Theme.of(context).colorScheme.primary;

                  textColor = Theme.of(context).colorScheme.primary;

                  fontWeight = FontWeight.w700;
                }

                return InkWell(
                  onTap: () => widget.onSelected(e.id!),
                  child: Container(
                    height: 40.h,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        15.horizontalSpace,

                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: textColor,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            e.optionText!,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: textColor,
                              fontWeight: fontWeight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList() ??
              [],

          /// actions bar
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.selectedOption == null
                        ? null
                        : widget.onCheck,
                    borderRadius: BorderRadius.circular(8),
                    child: Opacity(
                      opacity: widget.selectedOption == null ? 0.5 : 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'فحص',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// show info only after solving
                if (widget.isChecked && widget.question.explanation != null)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showQuestionInfoDialog(
                          context,
                          information: widget.question.explanation,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.white),

                            const SizedBox(height: 4),

                            Text(
                              'معلومات',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: InkWell(
                    onTap: widget.onReset,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          const Icon(Icons.refresh, color: Colors.white),

                          const SizedBox(height: 4),

                          Text(
                            'إعادة',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.onEdit != null) ...{
                  Expanded(
                    child: InkWell(
                      onTap: widget.onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            const Icon(Icons.edit, color: Colors.white),

                            const SizedBox(height: 4),

                            Text(
                              'تعديل',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                },
                if (widget.onDelete != null) ...{
                  Expanded(
                    child:
                        BlocBuilder<
                          CourseContentManagementBloc,
                          CourseContentManagementState
                        >(
                          buildWhen: (p, c) =>
                              p.deleteFromLectureTransaction !=
                              c.deleteFromLectureTransaction,
                          builder: (context, state) {
                            return state
                                        .deleteFromLectureTransaction
                                        .isLoading &&
                                    state.currentlyDeletingQuestionsIds
                                        .contains(widget.question.id)
                                ? CoursatyAppLoader(color: Colors.white)
                                : InkWell(
                                    onTap: () {
                                      showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            title: Text(
                                              "تأكيد الحذف",
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                color: Colors.red,
                                              ),
                                            ),
                                            content: Text(
                                              "هل أنت متأكد من حذف هذا السؤال؟ لا يمكن التراجع عن هذه العملية.",
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                height: 1.6,
                                                color: context
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "إلغاء",
                                                  style: GoogleFonts.cairo(),
                                                ),
                                              ),

                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () {
                                                  widget.onDelete?.call();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "حذف",
                                                  style: GoogleFonts.cairo(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            'حذف',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                          },
                        ),
                  ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionGroup {
  const _QuestionGroup({required this.title, required this.questions});

  final String title;
  final List<QuestionModel> questions;
}
