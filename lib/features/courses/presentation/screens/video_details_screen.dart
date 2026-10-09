import 'package:coursaty_student_and_teacher/app/widgets/video_quality_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/security/secure_student_content.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/widgets/percent_indicator.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart'
    show CourseDetailsModel;
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_state.dart';
import 'package:coursaty_student_and_teacher/app/widgets/you_are_guest_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/widgets/my_video_widget_better_player.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/utils/extensions/int.dart';
import '../../../teachers/data/model/teacher_model.dart';

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({
    super.key,
    required this.courseId,
    required this.video,
    this.teacher,
    required this.fromNetwork,
    this.quality,
    this.isFree = false,
    this.courseDetailsModel,
    this.lectureDetailsModel,
  });

  final Video video;
  final String courseId;
  final Teacher? teacher;
  final bool fromNetwork;
  final String? quality;
  final bool isFree;
  final CourseDetailsModel? courseDetailsModel;
  final LectureDetailsModel? lectureDetailsModel;

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late final MyDownloadsState myDownloadsState;
  late final String? filePath;
  String videoName = '';
  ScreenCaptureLease? _captureLease;

  @override
  void initState() {
    super.initState();
    _captureLease = StudentContentProtection.claim();
    final prefs = GetIt.I<PrefsRepository>();
    if ((prefs.isGuest || prefs.token == null) && !widget.isFree) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showGuestContentDialog(context);
        context.pop();
      });
      return;
    }
    if (!widget.fromNetwork) {
      myDownloadsState = BlocProvider.of<MyDownloadsBloc>(context).state;
      filePath = myDownloadsState.urlToFileReferences[widget.video.id];
      videoName =
          widget.video.videoName ??
          filePath?.split('/').last.split('.').first ??
          '';
    }
    getLikesIfThereIsInternet(context);
  }

  @override
  void dispose() {
    _captureLease?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: widget.video.videoName ?? "تفاصيل الفيديو",
        onBackTap: () {
          context.pop();
        },
        // Offline downloads are a student entitlement; teachers stream only.
        action:
            !widget.fromNetwork ||
                GetIt.I<PrefsRepository>().isGuest ||
                GetIt.I<PrefsRepository>().isTeacher ||
                GetIt.I<PrefsRepository>().token == null
            ? null
            : BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
                builder: (context, state) {
                  return BlocBuilder<
                    DownloadingMediaBloc,
                    DownloadingMediaState
                  >(
                    builder: (context, downloadState) {
                      final url = widget.video.id!;
                      final canDownload =
                          widget.video.offlineDownloadEnabled ?? true;
                      return downloadState.downloadingStatus[url] == true
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
                                      backGroundColor: AppColors.greyNormal,
                                      textColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    BlocProvider.of<DownloadingMediaBloc>(
                                      context,
                                    ).add(
                                      CancelDownloadEvent(
                                        fileUrl: url,
                                        fileType: 'video',
                                        fileName: widget.video.videoName,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ],
                            )
                          : state.urlToFileReferences[url] == null &&
                                canDownload
                          ? InkWell(
                              onTap: () {
                                showVideoQualityDialog(
                                  context,
                                  toDownload: true,
                                  videoId: widget.video.id!,
                                  onChooseQuality: (context, quality) {
                                    BlocProvider.of<DownloadingMediaBloc>(
                                      context,
                                    ).add(
                                      DownloadFileEvent(
                                        fileUrl: url,
                                        downloadUrl: url,
                                        quality: quality,
                                        fileType: 'video',
                                        fileName: widget.video.videoName,
                                        courseId: widget.courseId,
                                        courseDetailsModel:
                                            widget.courseDetailsModel,
                                        lectureDetailsModel:
                                            widget.lectureDetailsModel,
                                        lectureId: widget.video.lectureId,
                                      ),
                                    );
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                AppAssets.iconDownload2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  );
                },
              ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: MyVideoWidgetBetterPlayer(
                    filePath: !widget.fromNetwork ? filePath : null,
                    videoUrl: widget.video.videoUrl,
                    preferredResolution: widget.quality ?? '720p',
                    videoName: videoName,
                    videoId: widget.video.id!,
                    isFromNetwork: widget.fromNetwork,
                    duration:
                        'مدة الفيديو  ${(widget.video.durationSeconds ?? 0).formatDurationFromSeconds()}',
                    segments: widget.video.segments ?? [],
                    teacher: widget.teacher,
                    videoDescription: widget.video.description,
                    courseId: widget.courseId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getLikesIfThereIsInternet(BuildContext context) async {
    bool lostConnection = await HelperFunctions.lostInternetConnection();
    final prefs = GetIt.I<PrefsRepository>();
    if (!lostConnection &&
        context.mounted &&
        !prefs.isGuest &&
        prefs.token != null) {
      BlocProvider.of<CoursesBloc>(
        context,
      ).add(GetVideoInteractionsEvent(widget.video.id!));
    }
  }
}
