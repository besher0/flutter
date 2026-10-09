import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/app/widgets/custom_choose_file_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/my_video_widget_better_player.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/int.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_video_segment_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_segment_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/widgets/percent_indicator.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/bloc/courses_bloc.dart';
import '../../../courses/presentation/widgets/course_free_checkbox.dart';
import '../../../courses/presentation/widgets/video_segement_item.dart';
import '../widgets/upsert_video_segment_dialog.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({
    super.key,
    required this.lectureId,
    required this.courseId,
    this.preferredResolution = '720p',
    this.video,
    this.isForEdit = true,
  });

  final String lectureId;
  final String courseId;
  final String preferredResolution;
  final Video? video;
  final bool isForEdit;

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final ValueNotifier<XFile?> chooseFile = ValueNotifier(null);

  late final TextEditingController name;
  late final TextEditingController description;
  late final TextEditingController sortOrder;
  late final TextEditingController videoSize;
  late final TextEditingController videoDuration;

  late final ValueNotifier<bool> isFree;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.video?.videoName ?? '');
    description = TextEditingController(text: widget.video?.description ?? '');
    sortOrder = TextEditingController(
      text: widget.video?.sortOrder?.toString() ?? '',
    );
    videoSize = TextEditingController();
    videoDuration = TextEditingController();

    isFree = ValueNotifier(widget.video?.isFree ?? false);
    if (widget.video != null) {
      BlocProvider.of<CourseContentManagementBloc>(
        context,
      ).add(GetVideoSegmentsEvent(widget.video!.id!));
    }
    chooseFile.addListener(() {
      if (chooseFile.value != null) {
        BlocProvider.of<CourseContentManagementBloc>(
          context,
        ).add(VideoSelectedEvent(file: chooseFile.value!));
      }
    });
    if (widget.isForEdit) {
      BlocProvider.of<CourseContentManagementBloc>(
        context,
      ).add(VideoSelectedEvent(file: null));
      BlocProvider.of<CourseContentManagementBloc>(context).upsertVideoParams =
          null;
    } else {
      _initializeCurrentUploadedData();
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void dispose() {
    name.dispose();
    description.dispose();
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
          title: widget.isForEdit ? "تعديل فيديو" : "إنشاء فيديو",
        ),
        floatingActionButton: widget.video == null
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: FloatingActionButton(
                  onPressed: () async {
                    final segment = await showUpsertSegmentDialog(context);
                    if (segment != null && context.mounted) {
                      BlocProvider.of<CourseContentManagementBloc>(context).add(
                        UpsertVideoSegmentEvent(
                          UpsertVideoSegmentParams(
                            videoId: widget.video!.id!,
                            endSeconds: segment.endSeconds,
                            startSeconds: segment.startSeconds!,
                            segmentName: segment.segmentName!,
                            sortOrder: segment.sortOrder,
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(Icons.add),
                ),
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
                      if (widget.video != null) ...{
                        MyVideoWidgetBetterPlayer(
                          videoName: widget.video!.videoName ?? '',
                          preferredResolution: widget.preferredResolution,
                          isFromNetwork: true,
                          duration:
                              widget.video!.durationSeconds
                                  ?.formatDurationFromSeconds() ??
                              '',
                          videoId: widget.video!.id!,
                          segments: [],
                          courseId: widget.courseId,
                        ),
                        10.verticalSpace,
                      },
                      if (widget.video != null) ...{
                        10.verticalSpace,
                        BlocConsumer<
                          CourseContentManagementBloc,
                          CourseContentManagementState
                        >(
                          buildWhen: (p, c) =>
                              p.upsertVideoSegment != c.upsertVideoSegment,
                          listenWhen: (p, c) =>
                              p.upsertVideoSegment != c.upsertVideoSegment,
                          listener: (context, state) {
                            if (state.upsertVideoSegment.isFailed) {
                              showMessage(state.errorMessage);
                            }
                          },
                          builder: (context, state) {
                            return state.upsertVideoSegment.isLoading
                                ? Center(child: CoursatyAppLoader())
                                : state.videoSegments.isEmpty
                                ? SizedBox.shrink()
                                : SizedBox(
                                    height: 100,
                                    child: ListView.separated(
                                      itemCount: state.videoSegments.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            10.verticalSpace,
                                            Divider(
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.1),
                                              indent: 22.w,
                                              endIndent: 22.w,
                                              height: 0,
                                            ),
                                            10.verticalSpace,
                                          ],
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        Segment p = state.videoSegments[index];
                                        return VideoSegementItem(
                                          index: index,
                                          segment: p,
                                          onEdit: () async {
                                            final segment =
                                                await showUpsertSegmentDialog(
                                                  context,
                                                  initialSegment: p,
                                                );
                                            if (segment != null &&
                                                context.mounted) {
                                              BlocProvider.of<
                                                    CourseContentManagementBloc
                                                  >(context)
                                                  .add(
                                                    UpsertVideoSegmentEvent(
                                                      UpsertVideoSegmentParams(
                                                        videoId:
                                                            widget.video!.id!,
                                                        segmentId: p.id!,
                                                        endSeconds:
                                                            segment.endSeconds,
                                                        startSeconds: segment
                                                            .startSeconds!,
                                                        segmentName: segment
                                                            .segmentName!,
                                                        sortOrder:
                                                            segment.sortOrder,
                                                      ),
                                                    ),
                                                  );
                                            }
                                          },
                                          onDelete: () {
                                            BlocProvider.of<
                                                  CourseContentManagementBloc
                                                >(context)
                                                .add(
                                                  DeleteVideoSegmentsEvent(
                                                    params:
                                                        DeleteVideoSegmentParams(
                                                          videoId:
                                                              widget.video!.id!,
                                                          segmentId: p.id!,
                                                        ),
                                                  ),
                                                );
                                          },
                                        );
                                      },
                                    ),
                                  );
                          },
                        ),
                      },
                      10.verticalSpace,
                      CoursatyTextField(
                        label: 'اسم الفيديو',
                        validator: _requiredValidator,
                        controller: name,
                      ),
                      10.verticalSpace,
                      CoursatyTextField(
                        label: 'عن الفيديو (اختياري)',
                        minLines: 3,
                        controller: description,
                      ),
                      10.verticalSpace,
                      CoursatyTextField(
                        label: 'ترتيب الفيديو (اختياري)',
                        minLines: 1,
                        controller: sortOrder,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      10.verticalSpace,
                      IsFreeCourseTile(
                        isFreeNotifier: isFree,
                        title: "الفيديو مجاني",
                        description:
                            "عند تفعيل هذا الخيار سيتمكن الطلاب من الوصول إلى الفيديو مجاناً",
                      ),
                      10.verticalSpace,
                      // if (!widget.isForEdit) ...{
                      CustomChooseFileButton(
                        title: "اختر فيديو",
                        usedForImage: false,
                        usedForFile: false,
                        choosedFile: chooseFile,
                        choosedFileSize: videoSize,
                        videoDuration: videoDuration,
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
                      BlocProvider.of<CoursesBloc>(context).add(
                        GetLectureDetailsEvent(
                          lectureId: widget.lectureId,
                          courseId: widget.courseId,
                        ),
                      );
                      context.pop();
                    }
                  },
                  builder: (context, state) {
                    final path = state.currentlyUploadingFile?.path;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (path != null &&
                              state.uploadingProgress.containsKey(path)) ...{
                            ProgressIndicatorWidget(
                              percent: state.uploadingProgress[path]!,
                              textColor: Theme.of(context).colorScheme.primary,
                            ),
                          } else if (state.upsertLecture.isLoading)
                            CoursatyAppLoader()
                          else
                            CoursatyPrimaryButton(
                              label: !widget.isForEdit ? 'إضافة' : "تعديل",
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (widget.video == null &&
                                      state.currentlyUploadingFile == null) {
                                    showMessage("رجاء قم باختيار فيديو");
                                    return;
                                  }
                                  BlocProvider.of<CourseContentManagementBloc>(
                                    context,
                                  ).add(
                                    UpsertVideoEvent(
                                      UpsertVideoParams(
                                        // Duration only describes a newly
                                        // chosen file; edits without one keep
                                        // the stored duration.
                                        duration:
                                            state.currentlyUploadingFile == null
                                            ? null
                                            : int.tryParse(videoDuration.text),
                                        videoName: name.text,
                                        lectureId: widget.lectureId,
                                        isFree: isFree.value,
                                        description:
                                            description.text.trim().isEmpty
                                            ? null
                                            : description.text,
                                        videoId: widget.video?.id,
                                        sortOrder: sortOrder.text.trim().isEmpty
                                            ? null
                                            : sortOrder.text,
                                        videoSize: videoSize.text.trim().isEmpty
                                            ? null
                                            : videoSize.text,
                                      ),
                                      courseId: widget.courseId,
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
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

  void _initializeCurrentUploadedData() {
    final UpsertVideoParams? params =
        GetIt.I<CourseContentManagementBloc>().upsertVideoParams;
    if (params != null) {
      setState(() {
        name.text = params.videoName;
        description.text = params.description ?? '';
        sortOrder.text = params.sortOrder ?? '';
        isFree.value = params.isFree;
        videoSize.text = params.videoSize ?? '';
        videoDuration.text = params.duration?.toString() ?? '';
      });
    }
  }
}
