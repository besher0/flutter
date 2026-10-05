import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/courses_bloc.dart';
import '../widgets/course_card.dart';

class CoursesByYearScreen extends StatefulWidget {
  const CoursesByYearScreen({super.key, required this.yearId});

  final String yearId;

  @override
  State<CoursesByYearScreen> createState() => _CoursesByYearScreenState();
}

class _CoursesByYearScreenState extends State<CoursesByYearScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCoursesByYearEvent(yearId: widget.yearId, reset: true));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: TitleAppBar(
          title: "كورسات",
          onBackTap: () => Navigator.of(context).pop(),
          onBellTap: () {
            context.push(GRouter.config.applicationRoutes.notifications);
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              BlocBuilder<CoursesBloc, CoursesState>(
                buildWhen: (p, c) =>
                    p.coursesOfYear.paginationStatus !=
                    c.coursesOfYear.paginationStatus,
                builder: (context, state) {
                  if (state.coursesOfYear.items.isEmpty &&
                      state.coursesOfYear.isLoading) {
                    return Center(child: CoursatyAppLoader());
                  }
                  return Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                  (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                                BlocProvider.of<CoursesBloc>(context).add(
                                  GetCoursesByYearEvent(yearId: widget.yearId),
                                );
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                final course = state.coursesOfYear.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: CourseCard(
                                    title: course.name ?? '',
                                    imageUrl: course.imageUrl ?? '',
                                    chips: [
                                      if (!(course.isFree ?? false))
                                        CourseChipData(
                                          '+${course.studentsCount ?? 0} طالب',
                                          AppAssets.iconUser,
                                          iconColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      if (course.year?.name != null)
                                        CourseChipData(
                                          course.year!.name!,
                                          AppAssets.iconLayers,
                                          iconColor: AppColors.secondary,
                                        ),
                                      if (course.season?.name != null)
                                        CourseChipData(
                                          course.season!.name!,
                                          AppAssets.iconDocument,
                                          iconColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      // CourseChipData(
                                      //   "${course.duration} ساعة",
                                      //   AppAssets.iconTimer,
                                      // ),
                                    ],
                                    onTap: () {
                                      context.push(
                                        "${GRouter.config.applicationRoutes.courseDetails}/${course.id}",
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          10.verticalSpace,
                          if (state.coursesOfYear.items.isNotEmpty &&
                              state.coursesOfYear.isLoading) ...{
                            Center(child: CoursatyAppLoader()),
                          },
                          15.verticalSpace,
                        ],
                      ),
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
