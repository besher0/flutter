import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/security/secure_student_content.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/pdf_viewer_for_decrypted_files_page.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/video_details_screen.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/widgets/tab_bar_delegate.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/screens/mcq_questions_screen.dart';
import '../../../courses/presentation/widgets/content_item.dart';
import '../../../courses/presentation/widgets/image_header.dart';
import '../bloc/my_downloads_state.dart';

class DownloadedLectureDetails extends StatefulWidget {
  const DownloadedLectureDetails({
    super.key,
    required this.courseId,
    required this.lectureDetailsModel,
  });

  final LectureDetailsModel lectureDetailsModel;
  final String courseId;

  @override
  State<DownloadedLectureDetails> createState() =>
      _DownloadedLectureDetailsState();
}

class _DownloadedLectureDetailsState extends State<DownloadedLectureDetails>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  ScreenCaptureLease? _captureLease;

  @override
  void initState() {
    super.initState();
    _captureLease = StudentContentProtection.claim();
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
        appBar: TitleAppBar(title: "تفاصيل المحاضرة"),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageHeader(
                            image:
                                widget.lectureDetailsModel.courseImageUrl ?? '',
                          ),
                          15.verticalSpace,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.lectureDetailsModel.lecture!.title!,
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
                                if (widget
                                        .lectureDetailsModel
                                        .lecture
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget
                                        .lectureDetailsModel
                                        .lecture!
                                        .description!,
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
            body: FutureBuilder(
              future: _deleteNotDownloadedFilesOnOfflineMode(
                files: widget.lectureDetailsModel.files ?? [],
                videos: widget.lectureDetailsModel.videos ?? [],
              ),
              builder: (context, snapShot) {
                if (snapShot.connectionState != ConnectionState.done) {
                  return Center(child: CoursatyAppLoader());
                }
                final files = snapShot.data['files'];
                final videos = snapShot.data['videos'];
                return TabBarView(
                  controller: _tabs,
                  children: [
                    _FilesTab(courseId: widget.courseId, files: files),
                    _VideosTab(
                      courseId: widget.courseId,
                      videos: videos,
                      lectureDetailsModel: widget.lectureDetailsModel,
                    ),
                    _McqTab(
                      courseId: widget.courseId,
                      questions: widget.lectureDetailsModel.questions ?? [],
                      lectureDetailsModel: widget.lectureDetailsModel,
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

  Future<dynamic>? _deleteNotDownloadedFilesOnOfflineMode({
    required List<FileElement> files,
    required List<Video> videos,
  }) async {
    if (!await HelperFunctions.lostInternetConnection()) {
      return {'files': files, 'videos': videos};
    }
    if (mounted) {
      final savedUrls = context
          .read<MyDownloadsBloc>()
          .state
          .urlToFileReferences;
      files.removeWhere((item) => savedUrls[item.fileUrl!] == null);
      videos.removeWhere((item) => savedUrls[item.id!] == null);
      return {'files': files, 'videos': videos};
    }
  }
}

class _FilesTab extends StatelessWidget {
  const _FilesTab({required this.files, required this.courseId});

  final List<FileElement> files;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
      bloc: GetIt.I<MyDownloadsBloc>(),
      builder: (context, state) {
        List<FileElement> downloaded = List.of(files);
        final existUrls = context
            .read<MyDownloadsBloc>()
            .state
            .urlToFileReferences;
        downloaded.removeWhere((item) {
          final url = item.fileUrl!;
          return existUrls[url] == null;
        });
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: downloaded.length,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final url = downloaded[i].fileUrl!;
            final filePath = existUrls[url];
            return ContentItem(
              isExist: true,
              fileUrl: url,
              isVideo: false,
              onTap: () {
                context.pushPage(
                  LectureViewer(
                    lecture: downloaded[i],
                    filePath: filePath!,
                    fromNetwork: false,
                  ),
                );
              },
              actions: [],
              title: downloaded[i].fileName ?? '',
              index: i,
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
    required this.lectureDetailsModel,
  });

  final String courseId;
  final List<Video> videos;
  final LectureDetailsModel lectureDetailsModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
      bloc: GetIt.I<MyDownloadsBloc>(),
      builder: (context, state) {
        List<Video> downloaded = List.of(videos);
        final existUrls = context
            .read<MyDownloadsBloc>()
            .state
            .urlToFileReferences;
        downloaded.removeWhere((item) {
          final url = item.id!;
          return existUrls[url] == null;
        });
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: NeverScrollableScrollPhysics(),
          itemCount: downloaded.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final url = downloaded[i].id!;
            return ContentItem(
              isExist: true,
              fileUrl: url,
              isVideo: true,
              onTap: () {
                context.pushPage(
                  VideoDetailsScreen(
                    video: downloaded[i],
                    courseId: courseId,
                    fromNetwork: false,
                    teacher: lectureDetailsModel.teacher,
                  ),
                );
              },
              actions: [],
              title: videos[i].videoName ?? '',
              index: i,
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
    required this.lectureDetailsModel,
  });

  final String courseId;
  final List<QuestionModel> questions;
  final LectureDetailsModel lectureDetailsModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              context.pushPage(
                McqQuestionsScreen(
                  questions: questions,
                  courseId: courseId,
                  fromNetwork: false,
                  lectureDetailsModelFromDownload: lectureDetailsModel,
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
        ],
      ),
    );
  }
}
