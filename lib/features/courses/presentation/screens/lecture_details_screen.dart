import 'dart:io';

import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/subscribe_to_course.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/security/secure_student_content.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/pdf_viewer_for_decrypted_files_page.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/video_details_screen.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/widgets/tab_bar_delegate.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../app/widgets/video_quality_dialog.dart';
import '../../../../app/widgets/you_are_guest_dialog.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../course_content_management/presentation/widgets/percent_indicator.dart';
import '../../../my_downloads/presentation/bloc/my_downloads_state.dart';
import '../widgets/content_item.dart';
import '../widgets/image_header.dart';
import 'mcq_questions_screen.dart';
import 'lecture_file_access.dart';

class LectureDetailsScreen extends StatefulWidget {
  const LectureDetailsScreen({
    super.key,
    required this.courseId,
    required this.lectureId,
    required this.lectureName,
    required this.isCourseFree,
  });

  final String courseId;
  final String lectureId;
  final String lectureName;
  final bool isCourseFree;

  @override
  State<LectureDetailsScreen> createState() => _LectureDetailsScreenState();
}

class _LectureDetailsScreenState extends State<LectureDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  ScreenCaptureLease? _captureLease;

  void _fetchData() {
    BlocProvider.of<CoursesBloc>(context).add(
      GetLectureDetailsEvent(
        lectureId: widget.lectureId,
        courseId: widget.courseId,
      ),
    );
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCourseDetailsEvent(courseId: widget.courseId));
  }

  void _fetchActiveCourses() {
    BlocProvider.of<HomeBloc>(context).add(GetMyActiveCourses());
  }

  @override
  void initState() {
    super.initState();
    _captureLease = StudentContentProtection.claim();
    _fetchData();
    _fetchActiveCourses();
  }

  @override
  void dispose() {
    _captureLease?.release();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: "تفاصيل المحاضرة",
          onShareTap: () {
            Share.share(
              'https://coursay.duckdns.org/lecture?lid=${widget.lectureId}&name=${Uri.encodeComponent(widget.lectureName)}&cid=${widget.courseId}${widget.isCourseFree ? "&fc=_de24s2l" : ''}',
            );
          },
        ),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      BlocBuilder<CoursesBloc, CoursesState>(
                        buildWhen: (p, c) =>
                            p.getLectureDetails != c.getLectureDetails,
                        builder: (context, state) {
                          if (state.getLectureDetails.isLoading) {
                            return Center(child: CoursatyAppLoader());
                          }

                          if (state.getLectureDetails.isFailed) {
                            return Center(
                              child: TryAgainWidget(onPress: _fetchData),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ImageHeader(
                                image:
                                    state.lectureDetailsModel?.courseImageUrl ??
                                    '',
                              ),
                              15.verticalSpace,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.lectureName,
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                      style: GoogleFonts.cairo(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),

                                    if (state
                                            .lectureDetailsModel
                                            ?.lecture
                                            ?.description !=
                                        null) ...[
                                      15.verticalSpace,

                                      Row(
                                        children: [
                                          Text(
                                            'عن المحاضرة',
                                            style: GoogleFonts.cairo(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                          // BlocBuilder<
                                          //   DownloadingMediaBloc,
                                          //   DownloadingMediaState
                                          // >(
                                          //   buildWhen: (p, c) =>
                                          //       p.currentDownloadingTasks !=
                                          //       c.currentDownloadingTasks,
                                          //   builder: (context, state) {
                                          //     return state.currentDownloadingTasks > 0
                                          //         ? CoursatyAppLoader()
                                          //         : Padding(
                                          //             padding:
                                          //                 HWEdgeInsetsDirectional.only(
                                          //                   start: 10,
                                          //                 ),
                                          //             child: InkWell(
                                          //               splashColor: Colors.transparent,
                                          //               highlightColor:
                                          //                   Colors.transparent,
                                          //               onTap: _downloadAll,
                                          //               child: SvgPicture.asset(
                                          //                 AppAssets.iconDownload2,
                                          //                 height: 25,
                                          //                 colorFilter: ColorFilter.mode(
                                          //                   Theme.of(
                                          //                     context,
                                          //                   ).colorScheme.primary,
                                          //                   BlendMode.srcIn,
                                          //                 ),
                                          //               ),
                                          //             ),
                                          //           );
                                          //   },
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        state
                                                .lectureDetailsModel
                                                ?.lecture
                                                ?.description ??
                                            '',
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          height: 1.8,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: TabBarDelegate(
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
                  ),
                ),
              ];
            },
            body: BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                if (state.getLectureDetails.isLoading) {
                  return Center(child: CoursatyAppLoader());
                }
                final files = state.lectureDetailsModel?.files ?? [];
                final videos = state.lectureDetailsModel?.videos ?? [];
                return TabBarView(
                  controller: _tabs,
                  children: [
                    _FilesTab(
                      courseId: widget.courseId,
                      refresh: () {
                        _fetchData();
                        _fetchActiveCourses();
                      },
                      courseDetailsModel: state.courseDetailsModel,
                      lectureDetailsModel: state.lectureDetailsModel,
                      files: files,
                      isCourseFree: widget.isCourseFree,
                    ),
                    _VideosTab(
                      courseId: widget.courseId,
                      refresh: () {
                        _fetchData();
                        _fetchActiveCourses();
                      },
                      videos: videos,
                      isCourseFree: widget.isCourseFree,
                      courseDetailsModel: state.courseDetailsModel,
                      lectureDetailsModel: state.lectureDetailsModel,
                    ),
                    _McqTab(
                      courseId: widget.courseId,
                      refresh: () {
                        _fetchData();
                        _fetchActiveCourses();
                      },
                      isCourseFree: widget.isCourseFree,
                      courseDetailsModel: state.courseDetailsModel,
                      lectureDetailsModel: state.lectureDetailsModel,
                      questions: state.lectureDetailsModel?.questions ?? [],
                    ),
                  ],
                );
              },
            ),
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
    required this.isCourseFree,
    required this.refresh,
    this.courseDetailsModel,
    this.lectureDetailsModel,
  });

  final List<FileElement> files;
  final String courseId;
  final bool isCourseFree;
  final void Function() refresh;
  final CourseDetailsModel? courseDetailsModel;
  final LectureDetailsModel? lectureDetailsModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
      bloc: GetIt.I<MyDownloadsBloc>(),
      builder: (context, myDownloadState) {
        return BlocBuilder<DownloadingMediaBloc, DownloadingMediaState>(
          bloc: GetIt.I<DownloadingMediaBloc>(),
          builder: (context, downloadState) {
            return BlocBuilder<HomeBloc, HomeState>(
              bloc: GetIt.I<HomeBloc>(),
              // buildWhen: (p, c) => p.getActiveCourses != c.getActiveCourses,
              builder: (context, state) {
                if (state.getActiveCourses.isFailed) {
                  return Center(
                    child: TryAgainWidget(
                      onPress: () {
                        BlocProvider.of<HomeBloc>(
                          context,
                        ).add(GetMyActiveCourses());
                      },
                    ),
                  );
                }

                return state.getActiveCourses.isLoading
                    ? CoursatyAppLoader()
                    : RefreshIndicator(
                        onRefresh: () async {
                          refresh();
                        },
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: files.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final url = files[i].fileUrl;
                            final prefs = GetIt.I<PrefsRepository>();
                            final isGuest =
                                prefs.isGuest || prefs.token == null;
                            final isLocked = isLectureFileLocked(
                              file: files[i],
                              courseId: courseId,
                              isCourseFree: isCourseFree,
                              isGuest: isGuest,
                              activeCourseIds: state.activeCourses
                                  .map((item) => item.id)
                                  .whereType<String>(),
                            );
                            final filePath =
                                myDownloadState.urlToFileReferences[url];
                            final bool fileExist =
                                !isLocked &&
                                filePath != null &&
                                (filePath.startsWith('secure-hls://') ||
                                    File(filePath).existsSync());
                            return ContentItem(
                              itemColor: isLocked ? AppColors.greyDark : null,
                              isExist: fileExist,
                              fileUrl: url,
                              isVideo: false,
                              onTap: () {
                                if (isLocked) {
                                  showSubscribeToCourseDialog(
                                    context,
                                    courseId: courseId,
                                  );
                                  return;
                                }
                                if (fileExist) {
                                  context.pushPage(
                                    LectureViewer(
                                      lecture: files[i],
                                      filePath: filePath,
                                    ),
                                  );
                                } else if (canOpenLectureFileAsGuest(
                                  file: files[i],
                                  isCourseFree: isCourseFree,
                                  isGuest: isGuest,
                                )) {
                                  context.pushPage(
                                    LectureViewer(
                                      lecture: files[i],
                                      filePath: url!,
                                      fromNetwork: true,
                                    ),
                                  );
                                } else {
                                  BlocProvider.of<DownloadingMediaBloc>(
                                    context,
                                  ).add(
                                    DownloadFileEvent(
                                      fileUrl: url!,
                                      fileType: 'file',
                                      downloadUrl: url,
                                      fileName: files[i].fileName,
                                      courseId: courseId,
                                      lectureId: lectureDetailsModel?.lecture?.id,
                                      courseDetailsModel: courseDetailsModel,
                                      lectureDetailsModel: lectureDetailsModel,
                                    ),
                                  );
                                }
                              },
                              size: fileExist ? null : files[i].size,
                              actions: [
                                if (fileExist) ...{
                                  SvgPicture.asset(
                                    AppAssets.iconDocument,
                                    color: i % 2 == 0
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.secondary,
                                    height: 25,
                                  ),
                                },
                                if (isLocked) ...{
                                  SvgPicture.asset(
                                    AppAssets.iconLock,
                                    color: isLocked
                                        ? AppColors.greyDark
                                        : i % 2 == 0
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.secondary,
                                    height: 25,
                                  ),
                                },
                                if (!fileExist && !isGuest) ...{
                                  downloadState.downloadingStatus[url] == true
                                      ? Row(
                                          spacing: 5,
                                          children: [
                                            SizedBox(
                                              height: 30.r,
                                              width: 30.r,
                                              child: FittedBox(
                                                child: ProgressIndicatorWidget(
                                                  percent:
                                                      (downloadState
                                                          .downloadingProcesses[url] ??
                                                      0),
                                                  backGroundColor:
                                                      AppColors.greyNormal,
                                                  textColor: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                if (isLocked) {
                                                  showSubscribeToCourseDialog(
                                                    context,
                                                    courseId: courseId,
                                                  );
                                                  return;
                                                }
                                                BlocProvider.of<
                                                      DownloadingMediaBloc
                                                    >(context)
                                                    .add(
                                                      CancelDownloadEvent(
                                                        fileUrl: url!,
                                                        fileType: 'file',
                                                        fileName:
                                                            files[i].fileName,
                                                      ),
                                                    );
                                              },
                                              icon: Icon(
                                                Icons.cancel_outlined,
                                                color:
                                                    context.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        )
                                      : SvgPicture.asset(
                                          AppAssets.iconDownload2,
                                          color: isLocked
                                              ? AppColors.greyDark
                                              : i % 2 == 0
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : AppColors.secondary,
                                          height: 25,
                                        ),
                                },
                              ],
                              title: files[i].fileName ?? '',
                              index: i,
                            );
                          },
                        ),
                      );
              },
            );
          },
        );
      },
    );
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab({
    required this.videos,
    required this.courseId,
    required this.isCourseFree,
    required this.refresh,
    this.courseDetailsModel,
    this.lectureDetailsModel,
  });

  final String courseId;
  final List<Video> videos;
  final bool isCourseFree;
  final void Function() refresh;
  final CourseDetailsModel? courseDetailsModel;
  final LectureDetailsModel? lectureDetailsModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
      bloc: GetIt.I<MyDownloadsBloc>(),
      builder: (context, myDownloadState) {
        return BlocBuilder<DownloadingMediaBloc, DownloadingMediaState>(
          bloc: GetIt.I<DownloadingMediaBloc>(),
          builder: (context, downloadState) {
            return BlocBuilder<HomeBloc, HomeState>(
              bloc: GetIt.I<HomeBloc>(),
              // buildWhen: (p, c) => p.getActiveCourses != c.getActiveCourses,
              builder: (context, state) {
                if (state.getActiveCourses.isFailed) {
                  return Center(
                    child: TryAgainWidget(
                      onPress: () {
                        BlocProvider.of<HomeBloc>(
                          context,
                        ).add(GetMyActiveCourses());
                      },
                    ),
                  );
                }

                return state.getActiveCourses.isLoading
                    ? CoursatyAppLoader()
                    : RefreshIndicator(
                        onRefresh: () async {
                          refresh();
                        },
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: videos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final url = videos[i].id;
                            final canDownload =
                                videos[i].offlineDownloadEnabled ?? true;
                            final prefs = GetIt.I<PrefsRepository>();
                            final isGuest =
                                prefs.isGuest || prefs.token == null;
                            final isFree =
                                isCourseFree || (videos[i].isFree ?? false);
                            print(myDownloadState.urlToFileReferences);
                            bool isLocked =
                                url == null ||
                                videos[i].locked == true ||
                                (isGuest
                                    ? !(videos[i].isFree ?? false)
                                    : (!isFree &&
                                          !state.activeCourses.any(
                                            (item) => item.id == courseId,
                                          )));
                            bool videoExist =
                                !isLocked &&
                                myDownloadState.urlToFileReferences[url] !=
                                    null;
                            return ContentItem(
                              itemColor: isLocked ? AppColors.greyDark : null,
                              isExist: videoExist,
                              fileUrl: url,
                              isVideo: true,
                              // size: videoExist ? null : videos[i].videoSize,
                              onTap: () {
                                if (isLocked) {
                                  showSubscribeToCourseDialog(
                                    context,
                                    courseId: courseId,
                                  );
                                  return;
                                }
                                if (downloadState.downloadingStatus[url] ==
                                    true) {
                                  return;
                                }
                                if (videoExist) {
                                  context.pushPage(
                                    VideoDetailsScreen(
                                      video: videos[i],
                                      courseId: courseId,
                                      fromNetwork: false,
                                      isFree: videos[i].isFree ?? false,
                                      courseDetailsModel: courseDetailsModel,
                                      lectureDetailsModel: lectureDetailsModel,
                                      teacher: BlocProvider.of<CoursesBloc>(
                                        context,
                                        listen: false,
                                      ).state.lectureDetailsModel!.teacher,
                                    ),
                                  );
                                } else {
                                  showVideoQualityDialog(
                                    context,
                                    toDownload: false,
                                    videoId: videos[i].id!,

                                    onChooseQuality: (context, quality) {
                                      context.pushPage(
                                        VideoDetailsScreen(
                                          video: videos[i],
                                          courseId: courseId,
                                          quality: quality,
                                          fromNetwork: !videoExist,
                                          isFree: videos[i].isFree ?? false,
                                          courseDetailsModel:
                                              courseDetailsModel,
                                          lectureDetailsModel:
                                              lectureDetailsModel,
                                          teacher: BlocProvider.of<CoursesBloc>(
                                            context,
                                            listen: false,
                                          ).state.lectureDetailsModel!.teacher,
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              actions: [
                                if ((videos[i].isFree ?? false) ||
                                    videoExist) ...{
                                  SvgPicture.asset(
                                    AppAssets.iconPlayCircle,
                                    height: 30,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                },
                                if (isLocked) ...{
                                  SvgPicture.asset(
                                    AppAssets.iconLock,
                                    color: isLocked
                                        ? AppColors.greyDark
                                        : i % 2 == 0
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.secondary,
                                    height: 25,
                                  ),
                                },
                                if (!isGuest && !videoExist && canDownload) ...{
                                  downloadState.downloadingStatus[url] == true
                                      ? Row(
                                          spacing: 5,
                                          children: [
                                            SizedBox(
                                              height: 30.r,
                                              width: 30.r,
                                              child: FittedBox(
                                                child: ProgressIndicatorWidget(
                                                  percent:
                                                      (downloadState
                                                          .downloadingProcesses[url] ??
                                                      0),
                                                  backGroundColor:
                                                      AppColors.greyNormal,
                                                  textColor: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                BlocProvider.of<
                                                      DownloadingMediaBloc
                                                    >(context)
                                                    .add(
                                                      CancelDownloadEvent(
                                                        fileUrl: url!,
                                                        fileType: 'video',
                                                        fileName:
                                                            videos[i].videoName,
                                                      ),
                                                    );
                                              },
                                              icon: Icon(
                                                Icons.cancel_outlined,
                                                color:
                                                    context.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (isLocked) {
                                              showSubscribeToCourseDialog(
                                                context,
                                                courseId: courseId,
                                              );
                                              return;
                                            }
                                            showVideoQualityDialog(
                                              context,
                                              videoId: videos[i].id!,
                                              toDownload: true,
                                              onChooseQuality: (context, quality) {
                                                BlocProvider.of<
                                                      DownloadingMediaBloc
                                                    >(context)
                                                    .add(
                                                      DownloadFileEvent(
                                                        fileUrl: url,
                                                        downloadUrl: url,
                                                        quality: quality,
                                                        fileType: 'video',
                                                        fileName:
                                                            videos[i].videoName,
                                                        courseId: courseId,
                                                        lectureId:
                                                            videos[i].lectureId,
                                                        courseDetailsModel:
                                                            courseDetailsModel,
                                                        lectureDetailsModel:
                                                            lectureDetailsModel,
                                                      ),
                                                    );
                                              },
                                            );
                                          },
                                          child: SvgPicture.asset(
                                            AppAssets.iconDownload2,
                                            color: isLocked
                                                ? AppColors.greyDark
                                                : i % 2 == 0
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : AppColors.secondary,
                                            height: 25,
                                          ),
                                        ),
                                },
                              ],
                              title: videos[i].videoName ?? '',
                              index: i,
                            );
                          },
                        ),
                      );
              },
            );
          },
        );
      },
    );
  }
}

class _McqTab extends StatelessWidget {
  const _McqTab({
    required this.questions,
    required this.courseId,
    required this.isCourseFree,
    required this.refresh,
    this.courseDetailsModel,
    this.lectureDetailsModel,
  });

  final String courseId;
  final List<QuestionModel> questions;
  final bool isCourseFree;
  final void Function() refresh;
  final CourseDetailsModel? courseDetailsModel;
  final LectureDetailsModel? lectureDetailsModel;

  void _download(BuildContext context) {
    questions.forEach((item) {
      final url = item.imageUrl;
      if (url != null) {
        BlocProvider.of<DownloadingMediaBloc>(context).add(
          DownloadFileEvent(
            fileUrl: url,
            fileType: "image",
            downloadUrl: url,
            courseId: courseId,
            courseDetailsModel: courseDetailsModel,
            lectureDetailsModel: lectureDetailsModel,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
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
            if (questions.isNotEmpty) ...{
              15.verticalSpace,
              BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
                builder: (context, state) {
                  bool allDownloaded = true;
                  for (var item in questions) {
                    final url = item.imageUrl;
                    if (url != null && state.urlToFileReferences[url] == null) {
                      allDownloaded = false;
                      break;
                    }
                  }
                  return allDownloaded
                      ? SizedBox.shrink()
                      : BlocConsumer<
                          DownloadingMediaBloc,
                          DownloadingMediaState
                        >(
                          listenWhen: (p, c) =>
                              p.currentDownloadingImagesTasks !=
                                  c.currentDownloadingImagesTasks &&
                              c.currentDownloadingImagesTasks == 0,
                          listener: (context, state) {
                            showMessage("اكتمل التحميل");
                          },
                          builder: (context, state) {
                            return state.currentDownloadingImagesTasks > 0
                                ? CoursatyAppLoader()
                                : CoursatyPrimaryButton(
                                    label: "تحميل الأتمتات",
                                    onPressed: () {
                                      if (GetIt.I<PrefsRepository>().isGuest) {
                                        showGuestContentDialog(context);
                                        return;
                                      }
                                      if (!isCourseFree &&
                                          !context
                                              .read<HomeBloc>()
                                              .state
                                              .activeCourses
                                              .any(
                                                (item) => item.id == courseId,
                                              )) {
                                        showSubscribeToCourseDialog(
                                          context,
                                          courseId: courseId,
                                        );
                                        return;
                                      }
                                      _download(context);
                                    },
                                  );
                          },
                        );
                },
              ),
              15.verticalSpace,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () {
                  if (GetIt.I<PrefsRepository>().isGuest) {
                    showGuestContentDialog(context);
                    return;
                  }
                  if (!isCourseFree &&
                      !context.read<HomeBloc>().state.activeCourses.any(
                        (item) => item.id == courseId,
                      )) {
                    showSubscribeToCourseDialog(context, courseId: courseId);
                    return;
                  }
                  context.pushPage(
                    McqQuestionsScreen(
                      questions: questions,
                      courseId: courseId,
                    ),
                  );
                },
                child: Text(
                  'بدء الأتمتة',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}
