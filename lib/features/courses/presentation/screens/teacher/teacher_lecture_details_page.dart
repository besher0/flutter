import 'dart:developer';

import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/app/widgets/video_quality_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_from_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/add_file_screen.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/add_video_screen.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/upsert_question_page.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/pdf_viewer_for_decrypted_files_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/widgets/delete_from_download_dialo.dart';
import '../../../../../app/widgets/title_app_bar.dart';
import '../../../../../core/common/constant/design/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../widgets/content_item.dart';
import '../mcq_questions_screen.dart';

class TeacherLectureDetailsPage extends StatefulWidget {
  const TeacherLectureDetailsPage({
    super.key,
    required this.courseId,
    required this.lectureId,
    required this.lectureName,
  });

  final String courseId;
  final String lectureId;
  final String lectureName;

  @override
  State<TeacherLectureDetailsPage> createState() =>
      _TeacherLectureDetailsPageState();
}

class _TeacherLectureDetailsPageState extends State<TeacherLectureDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    BlocProvider.of<CoursesBloc>(context).add(
      GetLectureDetailsEvent(
        lectureId: widget.lectureId,
        courseId: widget.courseId,
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(title: widget.lectureName),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                controller: _tabs,
                labelColor: AppColors.secondary,
                unselectedLabelColor: AppColors.greyNormal,
                indicatorColor: AppColors.secondary,
                dividerColor: AppColors.secondary.withValues(alpha: 0.1),
                labelStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'ملفات'),
                  Tab(text: 'فيديوهات'),
                  Tab(text: 'أتمتات'),
                ],
              ),
              BlocConsumer<
                CourseContentManagementBloc,
                CourseContentManagementState
              >(
                listenWhen: (p, c) => p.upsertLecture != c.upsertLecture,
                listener: (context, state) {
                  if (state.upsertLecture.isSuccess) {
                    BlocProvider.of<CoursesBloc>(context).add(
                      GetLectureDetailsEvent(
                        lectureId: widget.lectureId,
                        courseId: widget.courseId,
                      ),
                    );
                  }
                },
                builder: (context, managementState) {
                  return BlocBuilder<CoursesBloc, CoursesState>(
                    builder: (context, state) {
                      if (state.getLectureDetails.isLoading ||
                          state.getLectureDetails.isInit) {
                        return Center(child: CoursatyAppLoader());
                      }
                      if (state.getLectureDetails.isFailed) {
                        return TryAgainWidget(onPress: fetchData);
                      }
                      return Expanded(
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _FilesTab(
                              showLoading:
                                  managementState.upsertLecture.isLoading,
                              courseId: widget.courseId,
                              refresh: fetchData,
                              lectureId:
                                  state.lectureDetailsModel!.lecture!.id!,
                              files: state.lectureDetailsModel!.files ?? [],
                            ),
                            _VideosTab(
                              showLoading:
                                  managementState.upsertLecture.isLoading,
                              courseId: widget.courseId,
                              refresh: fetchData,
                              lectureId:
                                  state.lectureDetailsModel!.lecture!.id!,
                              videos: state.lectureDetailsModel!.videos ?? [],
                            ),
                            BlocBuilder<CoursesBloc, CoursesState>(
                              builder: (context, state) {
                                return _McqTab(
                                  showLoading:
                                      managementState.upsertLecture.isLoading,
                                  courseId: widget.courseId,
                                  refresh: fetchData,
                                  lectureId:
                                      state.lectureDetailsModel!.lecture!.id!,
                                  questions:
                                      state.lectureDetailsModel?.questions ??
                                      [],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilesTab extends StatelessWidget {
  const _FilesTab({
    required this.files,
    required this.courseId,
    required this.lectureId,
    required this.refresh,
    required this.showLoading,
  });

  final List<FileElement> files;
  final String courseId;
  final String lectureId;
  final void Function() refresh;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    if (showLoading) {
      return Center(child: CoursatyAppLoader());
    }
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              return ContentItem(
                isVideo: false,
                onTap: () {
                  context.pushPage(
                    LectureViewer(
                      lecture: files[i],
                      filePath: files[i].fileUrl!,
                      fromNetwork: true,
                    ),
                  );
                },
                title: files[i].fileName ?? '',
                index: i,
                actions: [],
                onDelete: () {
                  _deleteConfirmation(
                    context,
                    false,
                    DeleteFromCourseParams(
                      id: files[i].id!,
                      endpoint: EndPoints.deleteFile(files[i].id!),
                    ),
                    lectureId,
                    courseId,
                  );
                },
                onEdit: () {
                  context.pushPage(
                    AddFileScreen(
                      lectureId: lectureId,
                      courseId: courseId,
                      fileElement: files[i],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              context.pushPage(
                AddFileScreen(lectureId: lectureId, courseId: courseId),
              );
            },
          ),
        ),
      ],
    );
  }
}

Future<void> _deleteConfirmation(
  BuildContext context,
  bool isVideo,
  DeleteFromCourseParams params,
  String lectureId,
  String courseId,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => DeleteFromDownloadDialo(
      isVideo: isVideo,
      onConfirmed: () {
        context.pop();
        BlocProvider.of<CourseContentManagementBloc>(context).add(
          DeleteFromLectureEvent(
            params: params,
            lectureId: lectureId,
            courseId: courseId,
          ),
        );
      },
    ),
  );
}

class _VideosTab extends StatelessWidget {
  const _VideosTab({
    required this.videos,
    required this.courseId,
    required this.lectureId,
    required this.refresh,
    required this.showLoading,
  });

  final String lectureId;
  final String courseId;
  final List<Video> videos;
  final void Function() refresh;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        if (showLoading)
          Center(child: CoursatyAppLoader())
        else
          RefreshIndicator(
            onRefresh: () async {
              refresh();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                return ContentItem(
                  isVideo: true,
                  actions: [],
                  onEdit: () {
                    showVideoQualityDialog(
                      context,
                      toDownload: false,
                      videoId: videos[i].id!,
                      onChooseQuality: (context, quality) {
                        context.pushPage(
                          AddVideoScreen(
                            lectureId: lectureId,
                            courseId: courseId,
                            preferredResolution: quality,
                            video: videos[i],
                            isForEdit: true,
                          ),
                        );
                      },
                    );
                  },
                  onDelete: () {
                    _deleteConfirmation(
                      context,
                      false,
                      DeleteFromCourseParams(
                        id: videos[i].id!,
                        endpoint: EndPoints.deleteVideo(videos[i].id!),
                      ),
                      lectureId,
                      courseId,
                    );
                  },
                  onTap: () {
                    showVideoQualityDialog(
                      context,
                      toDownload: false,
                      videoId: videos[i].id!,
                      onChooseQuality: (context, quality) {
                        context.pushPage(
                          AddVideoScreen(
                            lectureId: lectureId,
                            courseId: courseId,
                            preferredResolution: quality,
                            video: videos[i],
                            isForEdit: true,
                          ),
                        );
                      },
                    );
                  },
                  title: videos[i].videoName ?? '',
                  index: i,
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              context.pushPage(
                AddVideoScreen(
                  lectureId: lectureId,
                  courseId: courseId,
                  isForEdit: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _McqTab extends StatelessWidget {
  const _McqTab({
    required this.questions,
    required this.courseId,
    required this.lectureId,
    required this.refresh,
    required this.showLoading,
  });

  final String lectureId;
  final String courseId;
  final List<QuestionModel> questions;
  final void Function() refresh;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    if (showLoading) {
      return Center(child: CoursatyAppLoader());
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                AppAssets.iconQuiz,
                height: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                '${questions.length} سؤال',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              CoursatyPrimaryButton(
                label: "عرض الأسئلة",
                onPressed: () {
                  context.pushPage(
                    BlocProvider.value(
                      value: BlocProvider.of<CoursesBloc>(context),
                      child: McqQuestionsScreen(
                        questions: questions,
                        courseId: courseId,
                        onEdit: (QuestionModel q) {
                          context.pushPage(
                            UpsertQuestionPage(
                              lectureId: lectureId,
                              courseId: courseId,
                              question: q,
                            ),
                          );
                        },
                        onDelete: (QuestionModel q) {
                          BlocProvider.of<CourseContentManagementBloc>(
                            context,
                          ).add(
                            DeleteQuestionEvent(
                              params: DeleteFromCourseParams(
                                id: q.id!,
                                endpoint: EndPoints.deleteQuestionEP(id: q.id!),
                              ),
                              lectureId: lectureId,
                              courseId: courseId,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              CoursatyPrimaryButton(
                label: "إضافة سؤال جديد",
                onPressed: () {
                  context.pushPage(
                    UpsertQuestionPage(
                      lectureId: lectureId,
                      courseId: courseId,
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
}
