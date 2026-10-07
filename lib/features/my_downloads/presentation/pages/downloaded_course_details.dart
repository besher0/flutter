import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:coursaty_student_and_teacher/app/widgets/paid_content_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/security/secure_student_content.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/int.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/widgets/delete_from_download_dialo.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/widgets/image_header.dart';
import '../../../courses/presentation/widgets/lecture_item.dart';
import '../../../courses/presentation/widgets/media_item.dart';

class DownloadedCourseDetails extends StatefulWidget {
  const DownloadedCourseDetails({super.key, required this.course});

  final CourseDetailsModel course;

  @override
  State<DownloadedCourseDetails> createState() =>
      _DownloadedCourseDetailsState();
}

class _DownloadedCourseDetailsState extends State<DownloadedCourseDetails>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  ScreenCaptureLease? _captureLease;

  @override
  void initState() {
    super.initState();
    _captureLease = StudentContentProtection.claim();
  }

  @override
  void dispose() {
    _captureLease?.release();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: 'تفاصيل الكورس',
        action: IconButton(
          onPressed: () {
            deleteCourse(context, widget.course.course!.id!);
          },
          icon: Icon(Icons.delete, color: context.colorScheme.error),
        ),
        onShareTap: () {
          Share.share(
            'https://coursay.duckdns.org/course?cid=${widget.course.course!.id}',
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageHeader(
                  courseId: widget.course.course!.id!,
                  image: widget.course.course?.imageUrl ?? '',
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.course.course?.name ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      10.horizontalSpace,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.course.course?.discountedPrice != null &&
                              widget.course.course?.basePrice !=
                                  widget.course.course?.discountedPrice) ...{
                            Text(
                              '${widget.course.course?.discountedPrice ?? ''} / ',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.red,
                              ),
                            ),
                            Text(
                              (widget.course.course?.basePrice ?? '')
                                  .toString(),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyDark,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.greyDark,
                              ),
                            ),
                          } else
                            Text(
                              (widget.course.course?.basePrice ?? '')
                                  .toString(),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.red,
                              ),
                            ),
                          5.horizontalSpace,
                          Text(
                            "ل.س",
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TabBar(
              dividerColor: AppColors.secondary.withValues(alpha: 0.1),
              controller: _tabController,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.greyDark,
              indicatorColor: AppColors.secondary,
              labelStyle: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'تفاصيل'),
                Tab(text: 'المحاضرات'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DetailsTab(
                    course: widget.course.course!,
                    details: widget.course.details!,
                  ),
                  _LecturesTab(
                    courseId: widget.course.course!.id!,
                    lectures: widget.course.lectures ?? [],
                    isFree: widget.course.course?.isFree ?? false,
                  ),
                ],
              ),
            ),
            15.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.details, required this.course});

  final Details details;
  final Course course;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                context.pushReplacement(
                  "${GRouter.config.applicationRoutes.teacherDetails}/${details.teacher!.id}/${details.teacher!.name}",
                );
              },
              child: details.teacher?.image == null
                  ? CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: SvgPicture.asset(
                        AppAssets.iconBoy,
                        height: 26,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(180),
                      child: CachedNetworkImage(
                        imageUrl: details.teacher!.image!,
                        width: 40.r,
                        height: 40.r,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => SizedBox(
                          width: 40.r,
                          height: 40.r,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
            ),
            10.horizontalSpace,
            Text(
              'أ. ${details.teacher?.name ?? ''}',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.secondary.withValues(alpha: 0.2)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ChipWidget(
              text: "${details.studentsCount ?? 0} طالب",
              iconPath: AppAssets.iconUser,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            if (details.year?.name != null)
              ChipWidget(
                text: details.year?.name ?? '',
                iconPath: AppAssets.iconLayers,
                iconColor: AppColors.secondary,
              ),
            if (details.season?.name != null)
              ChipWidget(
                text: details.season?.name ?? '',
                iconPath: AppAssets.iconDocument,
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ChipWidget(
              text: '${details.lecturesCount ?? 0} محاضرة',
              iconPath: AppAssets.iconBook,
              iconColor: AppColors.secondary,
            ),
            ChipWidget(
              text: (details.duration ?? 0).formatDurationAr(),
              iconPath: AppAssets.iconTimer,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            ChipWidget(
              text: '${details.videosCount ?? 0} فيديو',
              iconPath: AppAssets.iconVideo,
              iconColor: AppColors.secondary,
            ),
            ChipWidget(
              text: '${details.filesCount ?? 0} ملف',
              iconPath: AppAssets.iconFileText,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            ChipWidget(
              text: '${details.questionsCount ?? 0} سؤال أتمتة',
              iconPath: AppAssets.iconQuiz,
              iconColor: AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.secondary.withValues(alpha: 0.2)),
        const SizedBox(height: 12),
        Text(
          'عن الكورس',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.description ?? '',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.8,
          ),
        ),
        if (course.telegramUrl?.trim().isNotEmpty == true ||
            details.discussionGroupUrl?.trim().isNotEmpty == true ||
            details.introVideoUrl != null) ...{
          15.verticalSpace,
          Divider(color: AppColors.secondary.withValues(alpha: 0.2)),
          15.verticalSpace,
        },
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (details.instagramUrl?.trim().isNotEmpty == true) ...{
              MediaItem(
                assetUrl: AppAssets.instagram,
                isSvg: true,
                color: Color(0xffDB2877),
                onTap: () {
                  HelperFunctions.urlLauncher(details.instagramUrl!.trim());
                },
                title: "صفحة الانستا للاستاذ",
              ),
              15.verticalSpace,
            },
            if (course.telegramUrl?.trim().isNotEmpty == true) ...{
              MediaItem(
                assetUrl: AppAssets.telegram,
                color: Color(0xff1DA0E0),
                onTap: () {
                  HelperFunctions.urlLauncher(course.telegramUrl!.trim());
                },
                title: "قناة التلغرام",
              ),
              15.verticalSpace,
            },
            if (details.discussionGroupUrl?.trim().isNotEmpty == true) ...{
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return MediaItem(
                    assetUrl: AppAssets.telegram,
                    color: Color(0xff1DA0E0),
                    onTap: () {
                      if (state.activeCourses.any(
                        (item) => item.id == course.id,
                      )) {
                        showPaidContentDialog(context, courseId: course.id!);
                        return;
                      }
                      HelperFunctions.urlLauncher(
                        details.discussionGroupUrl!.trim(),
                      );
                    },
                    title: "مجموعة المتابعة مع الاستاذ",
                  );
                },
              ),
              15.verticalSpace,
            },
            if (details.introVideoUrl != null)
              MediaItem(
                assetUrl: AppAssets.youTube,
                color: Color(0xffDA0000),
                onTap: () {
                  HelperFunctions.urlLauncher(details.introVideoUrl!);
                },
                title: "مقدمة عاليوتيوب",
              ),
          ],
        ),
      ],
    );
  }
}

class _LecturesTab extends StatelessWidget {
  const _LecturesTab({
    required this.lectures,
    required this.courseId,
    required this.isFree,
  });

  final List<Lecture> lectures;
  final String courseId;
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 1,
      childAspectRatio: 3,
      mainAxisSpacing: 15.h,
      crossAxisSpacing: 15.w,
      padding: const EdgeInsets.all(16),
      children: List.generate(lectures.length, (index) {
        return InkWell(
          onTap: () {
            final lectureDetails = context
                .read<MyDownloadsBloc>()
                .state
                .lectureIdToLectureDetailsReferences[lectures[index].id!];
            if (lectureDetails == null) {
              showMessage("لم تقم بتحميل هذه المحاضرة");
              return;
            }
            context.push(
              "${GRouter.config.applicationRoutes.downloadedLectureDetails}/$courseId",
              extra: lectureDetails,
            );
          },
          child: LectureItem(index: index, lectureName: lectures[index].title!),
        );
      }),
    );
  }
}
