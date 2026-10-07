import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/empty_courses.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/teacher_empty_courses.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/widgets/chip_widget.dart';
import '../../../../app/widgets/you_are_guest_dialog.dart';
import '../../../../app/widgets/zoomable_image.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/common/helper/helper_functions.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/int.dart';
import '../../../courses/presentation/widgets/course_card.dart';

class TeacherDetailScreen extends StatefulWidget {
  const TeacherDetailScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  final String teacherId;
  final String teacherName;

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TeachersBloc>(
      context,
    ).add(GetTeacherDetailsEvent(teacherId: widget.teacherId, reset: true));
    BlocProvider.of<TeachersBloc>(context).add(GetLikedTeachersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TitleAppBar(
        title: widget.teacherName,
        onShareTap: () {
          Share.share(
            'https://coursay.duckdns.org/teacher?tid=${widget.teacherId}&name=${Uri.encodeComponent(widget.teacherName)}',
          );
        },
      ),
      body: SafeArea(
        child: BlocBuilder<TeachersBloc, TeachersState>(
          buildWhen: (p, c) =>
              p.teacherCourses.paginationStatus !=
              c.teacherCourses.paginationStatus,
          builder: (context, state) {
            if (state.teacherCourses.items.isEmpty &&
                state.teacherCourses.isLoading) {
              return Center(child: CoursatyAppLoader());
            }
            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<TeachersBloc>(context).add(
                  GetTeacherDetailsEvent(
                    teacherId: widget.teacherId,
                    reset: true,
                  ),
                );
                BlocProvider.of<TeachersBloc>(
                  context,
                ).add(GetLikedTeachersEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileRow(
                      id: state.teacherDetails?.id ?? '',
                      name: state.teacherDetails?.name ?? '',
                      avatarUrl: state.teacherDetails?.image,
                      coursesCount: (state.teacherDetails?.coursesCount ?? 0)
                          .toString(),
                    ),
                    15.verticalSpace,
                    if (state.teacherDetails?.description != null) ...{
                      Divider(height: 1, color: AppColors.primaryLightTrack),
                      15.verticalSpace,
                      _AboutSection(
                        aboutText: state.teacherDetails?.description ?? '',
                        instagram: state.teacherDetails?.instagramUrl,
                      ),
                      15.verticalSpace,
                    },
                    Divider(height: 1, color: AppColors.primaryLightTrack),
                    15.verticalSpace,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'الكورسات التي يقدمها المُدرِّس',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    15.verticalSpace,
                    state.teacherCourses.items.isEmpty
                        ? TeacherEmptyCourses()
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                  (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                                BlocProvider.of<TeachersBloc>(context).add(
                                  GetTeacherDetailsEvent(
                                    teacherId: state.teacherDetails!.id!,
                                  ),
                                );
                              }
                              return false;
                            },
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.teacherCourses.items.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final course =
                                    state.teacherCourses.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: CourseCard(
                                    title: course.name ?? '',
                                    height: 230,
                                    imageUrl: course.imageUrl ?? '',
                                    onTap: () {
                                      context.push(
                                        "${GRouter.config.applicationRoutes.courseDetails}/${course.id}",
                                      );
                                    },
                                    chips: [
                                      if (!(course.isFree ?? false))
                                        CourseChipData(
                                          '+${course.studentsCount ?? 0} طالب',
                                          AppAssets.iconUser,
                                          iconColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      if (course.year?.yearName != null)
                                        CourseChipData(
                                          course.year!.yearName!,
                                          AppAssets.iconLayers,
                                          iconColor: AppColors.secondary,
                                        ),
                                      if (course.season?.seasonName != null)
                                        CourseChipData(
                                          course.season!.seasonName!,
                                          AppAssets.iconDocument,
                                          iconColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      CourseChipData(
                                        (course.duration ?? 0)
                                            .formatDurationAr(),
                                        iconColor: AppColors.secondary,
                                        AppAssets.iconTimer,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                    10.verticalSpace,
                    if (state.teacherCourses.items.isNotEmpty &&
                        state.teacherCourses.isLoading) ...{
                      Center(child: CoursatyAppLoader()),
                    },
                    15.verticalSpace,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.coursesCount,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String coursesCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        avatarUrl == null
            ? CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: SvgPicture.asset(
                  AppAssets.iconBoy,
                  height: 35,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : ZoomableImage(
                imageUrl: avatarUrl!,
                height: 85,
                width: 85,
                borderRadius: BorderRadius.circular(41.5),
              ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChipWidget(
                  text: "$coursesCount كورس",
                  iconPath: AppAssets.iconBook,
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                BlocBuilder<TeachersBloc, TeachersState>(
                  buildWhen: (p, c) =>
                      p.likedTeachers.length != c.likedTeachers.length ||
                      p.interactionsStatus[id] != c.interactionsStatus[id],
                  builder: (context, state) {
                    bool isLiked = state.likedTeachers.any(
                      (item) => item.id == id,
                    );
                    return (state.interactionsStatus[id]?.isLoading ??
                            false || state.getMyLikedTeachers.isLoading)
                        ? CoursatyAppLoader()
                        : InkWell(
                            onTap: () {
                              if (GetIt.I<PrefsRepository>().isGuest) {
                                showGuestContentDialog(context);
                                return;
                              }
                              if (!isLiked) {
                                BlocProvider.of<TeachersBloc>(
                                  context,
                                ).add(LikeTeacherEvent(teacherId: id));
                              } else {
                                BlocProvider.of<TeachersBloc>(
                                  context,
                                ).add(UnLikeTeacherEvent(teacherId: id));
                              }
                            },
                            child: ChipWidget(
                              text: (state.teacherDetails?.likesCount ?? 0)
                                  .toString(),
                              iconPath: isLiked
                                  ? AppAssets.iconHeartFilled
                                  : AppAssets.iconHeart,
                              iconColor: const Color(0xFFC61F1F),
                            ),
                          );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
    width: 80,
    height: 83,
    color: AppColors.primaryLightTrack,
    child: Icon(Icons.person, color: AppColors.greyNormal, size: 40),
  );
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.aboutText, this.instagram});

  final String aboutText;
  final String? instagram;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عن المُدرِّس',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                height: 1.4,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (instagram != null) ...{
                  InkWell(
                    onTap: () {
                      HelperFunctions.urlLauncher(instagram!);
                    },
                    child: SvgPicture.asset(AppAssets.instagram, height: 30),
                  ),
                  10.horizontalSpace,
                },
              ],
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          aboutText,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.greyDarkActive,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
