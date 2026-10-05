import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/empty_courses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/int.dart';
import '../bloc/courses_bloc.dart';
import '../widgets/course_card.dart';

class CoursesBySubjectScreen extends StatefulWidget {
  const CoursesBySubjectScreen({
    super.key,
    required this.subjectId,
    required this.isForSubject,
  });

  final String subjectId;
  final bool isForSubject;

  @override
  State<CoursesBySubjectScreen> createState() => _CoursesBySubjectScreenState();
}

class _CoursesBySubjectScreenState extends State<CoursesBySubjectScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCoursesBySubjectEvent(widget.subjectId, reset: true));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: TitleAppBar(
          title: "كورسات ${widget.isForSubject ? "المادة" : "البرنامج"}",
          onBackTap: () => Navigator.of(context).pop(),
          onBellTap: () {
            context.push(GRouter.config.applicationRoutes.notifications);
          },
        ),
        body: SafeArea(
          child: BlocBuilder<CoursesBloc, CoursesState>(
            buildWhen: (p, c) =>
                p.coursesOfSubject.paginationStatus !=
                c.coursesOfSubject.paginationStatus,
            builder: (context, state) {
              if (state.coursesOfSubject.items.isEmpty &&
                  state.coursesOfSubject.isLoading) {
                return Center(child: CoursatyAppLoader());
              }
              if (state.coursesOfSubject.items.isEmpty) {
                return EmptyCourses(
                  fromSubjects: widget.isForSubject,
                  fromPrograms: !widget.isForSubject,
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                            BlocProvider.of<CoursesBloc>(
                              context,
                            ).add(GetCoursesBySubjectEvent(widget.subjectId));
                          }
                          return false;
                        },
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.coursesOfSubject.items.length,
                          itemBuilder: (context, index) {
                            final course = state.coursesOfSubject.items[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 16,
                                top: 16,
                              ),
                              child: CourseCard(
                                height: 230,
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
                                  CourseChipData(
                                    (course.duration ?? 0).formatDurationAr(),
                                    AppAssets.iconTimer,
                                    iconColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
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
                    ),
                    10.verticalSpace,
                    if (state.coursesOfYear.items.isNotEmpty &&
                        state.coursesOfYear.isLoading) ...{
                      Center(child: CoursatyAppLoader()),
                    },
                    15.verticalSpace,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
