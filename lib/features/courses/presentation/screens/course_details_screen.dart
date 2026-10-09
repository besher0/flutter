import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/paid_content_dialog.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/int.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/widgets/subscribe_to_course.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../app/widgets/you_are_guest_dialog.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../widgets/image_header.dart';
import '../widgets/lecture_item.dart';
import '../widgets/media_item.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  void _fetchActiveCourses() {
    BlocProvider.of<HomeBloc>(context).add(GetMyActiveCourses());
  }

  void _fetchData() {
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCourseDetailsEvent(courseId: widget.courseId));
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCourseRating(courseId: widget.courseId));
    _fetchActiveCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoursesBloc, CoursesState>(
      listenWhen: (p, c) =>
          !GetIt.I<PrefsRepository>().isGuest &&
          p.rateCourseOrGetCourseRateStatus !=
              c.rateCourseOrGetCourseRateStatus,
      listener: (context, state) {
        if (state.rateCourseOrGetCourseRateStatus.isFailed) {
          showMessage(state.errorMessage);
        }
      },
      child: Scaffold(
        appBar: TitleAppBar(
          title: 'تفاصيل الكورس',
          onShareTap: () {
            Share.share(
              'https://coursay.duckdns.org/course?cid=${widget.courseId}',
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              BlocBuilder<CoursesBloc, CoursesState>(
                buildWhen: (p, c) =>
                    p.getCourseDetailsStatus != c.getCourseDetailsStatus,
                builder: (context, state) {
                  if (state.getCourseDetailsStatus.isLoading) {
                    return Center(child: CoursatyAppLoader());
                  }

                  if (state.getCourseDetailsStatus.isFailed) {
                    return Center(child: TryAgainWidget(onPress: _fetchData));
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageHeader(
                        courseId: widget.courseId,
                        image: state.courseDetailsModel?.course?.imageUrl ?? '',
                        isFreeCourse:
                            state.courseDetailsModel?.course?.isFree ?? false,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                (state.courseDetailsModel?.course?.name ?? ''),
                                maxLines: 3,
                                overflow: TextOverflow.visible,
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            // Hidden entirely (base, discount, final) when the
                            // course price is not visible to students.
                            if (state.courseDetailsModel?.course?.isPriceVisible ??
                                true) ...[
                              10.horizontalSpace,
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (state
                                              .courseDetailsModel
                                              ?.course
                                              ?.discountedPrice !=
                                          null &&
                                      state
                                              .courseDetailsModel
                                              ?.course
                                              ?.basePrice !=
                                          state
                                              .courseDetailsModel
                                              ?.course
                                              ?.discountedPrice) ...{
                                    Text(
                                      '${state.courseDetailsModel?.course?.discountedPrice ?? ''} / ',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.red,
                                      ),
                                    ),
                                    Text(
                                      (state
                                                  .courseDetailsModel
                                                  ?.course
                                                  ?.basePrice ??
                                              '')
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
                                      (state
                                                  .courseDetailsModel
                                                  ?.course
                                                  ?.basePrice ??
                                              '')
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
              BlocBuilder<CoursesBloc, CoursesState>(
                buildWhen: (p, c) =>
                    p.getCourseDetailsStatus != c.getCourseDetailsStatus,
                builder: (context, state) {
                  if (state.getCourseDetailsStatus.isLoading ||
                      state.courseDetailsModel == null) {
                    return Center(child: CoursatyAppLoader());
                  }
                  return Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _DetailsTab(
                          course: state.courseDetailsModel!.course!,
                          details: state.courseDetailsModel!.details!,
                        ),
                        _LecturesTab(
                          courseId: widget.courseId,
                          lectures: state.courseDetailsModel?.lectures ?? [],
                          isFree:
                              state.courseDetailsModel!.course?.isFree ?? false,
                        ),
                      ],
                    ),
                  );
                },
              ),
              15.verticalSpace,
              BlocBuilder<CoursesBloc, CoursesState>(
                buildWhen: (p, c) =>
                    p.getCourseDetailsStatus != c.getCourseDetailsStatus,
                builder: (context, state) {
                  final course = state.courseDetailsModel?.course;
                  final details = state.courseDetailsModel?.details;
                  final isExpired =
                      details?.isExpired == true ||
                      (details?.expiresAt != null &&
                          !details!.expiresAt!.isAfter(DateTime.now()));
                  final finalPrice =
                      course?.discountedPrice ?? course?.basePrice ?? 0;
                  return !state.getCourseDetailsStatus.isSuccess
                      ? SizedBox.shrink()
                      : (course?.isFree ?? false)
                      ? SizedBox.shrink()
                      : isExpired
                      ? const _SubscriptionUnavailableNotice(
                          text:
                              'انتهت صلاحية هذا الكورس ولا يمكن بدء الاشتراك.',
                        )
                      : finalPrice <= 0
                      ? const _SubscriptionUnavailableNotice(
                          text: 'لا يمكن بدء الاشتراك لأن سعر الكورس غير صالح.',
                        )
                      : course?.paymentQrUrl?.trim().isNotEmpty != true
                      ? const _SubscriptionUnavailableNotice(
                          text: 'رمز الدفع غير متاح لهذا الكورس حالياً.',
                        )
                      : BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if (state.getActiveCourses.isFailed) {
                              return Center(
                                child: TryAgainWidget(
                                  onPress: _fetchActiveCourses,
                                ),
                              );
                            }
                            return state.activeCourses.any(
                                  (item) => item.id == widget.courseId,
                                )
                                ? SizedBox.shrink()
                                : Padding(
                                    padding: HWEdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: BlocBuilder<AppBloc, AppState>(
                                      buildWhen: (p, c) =>
                                          p.scanCode != c.scanCode,
                                      builder: (context, state) {
                                        return state.scanCode.isLoading
                                            ? CoursatyAppLoader()
                                            : CoursatyPrimaryButton(
                                                label: 'اشترك بالكورس',
                                                onPressed: () {
                                                  if (GetIt.I<PrefsRepository>()
                                                      .isGuest) {
                                                    showGuestContentDialog(
                                                      context,
                                                    );
                                                    return;
                                                  }
                                                  showSubscribeToCourseDialog(
                                                    context,
                                                    courseId: widget.courseId,
                                                  );
                                                },
                                              );
                                      },
                                    ),
                                  );
                          },
                        );
                },
              ),
              15.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionUnavailableNotice extends StatelessWidget {
  const _SubscriptionUnavailableNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.details, required this.course});

  final Details details;
  final Course course;

  /// The backend sends the course Telegram link under `details`; `course`
  /// is kept as a fallback for older cached downloads.
  String? get _telegramUrl => details.telegramUrl ?? course.telegramUrl;

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
            if (!(course.isFree ?? false))
              ChipWidget(
                text: "${details.studentsCount ?? 0} طالب",
                iconPath: AppAssets.iconUser,
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            if (details.year?.name != null)
              ChipWidget(
                text: details.year!.name!,
                iconPath: AppAssets.iconLayers,
                iconColor: AppColors.secondary,
              ),
            if (details.season?.name != null)
              ChipWidget(
                text: details.season!.name!,
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
        if (_telegramUrl?.trim().isNotEmpty == true ||
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
            if (details.instagramUrl != null) ...{
              MediaItem(
                assetUrl: AppAssets.instagram,
                isSvg: true,
                color: Color(0xffDB2877),
                onTap: () {
                  HelperFunctions.urlLauncher(details.instagramUrl!);
                },
                title: "صفحة الانستا للاستاذ",
              ),
              15.verticalSpace,
            },
            if (_telegramUrl?.trim().isNotEmpty == true) ...{
              MediaItem(
                assetUrl: AppAssets.telegram,
                color: Color(0xff1DA0E0),
                onTap: () {
                  HelperFunctions.urlLauncher(_telegramUrl!.trim());
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
                      if (!state.activeCourses.any(
                            (item) => item.id == course.id,
                          ) &&
                          !(course.isFree ?? false)) {
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
      childAspectRatio: context.fullWidth > 450 ? 4 : 3.h,
      mainAxisSpacing: 15.h,
      crossAxisSpacing: 15.w,
      padding: const EdgeInsets.all(16),
      children: List.generate(lectures.length, (index) {
        return InkWell(
          onTap: () {
            context.push(
              "${GRouter.config.applicationRoutes.lectureDetails}/${lectures[index].id}/${lectures[index].title}/$courseId/$isFree",
            );
          },
          child: LectureItem(index: index, lectureName: lectures[index].title!),
        );
      }),
    );
  }
}
