import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable_generator/utils.dart';

import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/courses_bloc.dart';
import '../widgets/course_card.dart';

class MoreCoursesPage extends StatefulWidget {
  const MoreCoursesPage({
    super.key,
    required this.categoryId,
    this.filter,
    required this.yearId,
  });

  final String? categoryId;
  final String? filter;
  final String yearId;

  @override
  State<MoreCoursesPage> createState() => _MoreCoursesPageState();
}

class _MoreCoursesPageState extends State<MoreCoursesPage> {
  void _getCoursesWithFiltering({bool reset = false}) {
    BlocProvider.of<CoursesBloc>(context).add(
      GetCoursesWithFilteringEvent(
        filter: widget.filter,
        categoryId: widget.filter == null ? widget.categoryId : null,
        reset: reset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "كورسات"),
      body: Column(
        children: [
          BlocBuilder<CoursesBloc, CoursesState>(
            buildWhen: (p, c) =>
                p.coursesWithFiltering.paginationStatus !=
                c.coursesWithFiltering.paginationStatus,
            builder: (context, state) {
              final List<CourseModel> courses =
                  state.coursesWithFiltering.items
                      .firstWhereOrNull(
                        (item) => item.year?.id == widget.yearId,
                      )
                      ?.courses ??
                  [];
              if (courses.isEmpty && state.coursesWithFiltering.isLoading) {
                return SizedBox(
                  height: 1.sh - 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CoursatyAppLoader()],
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                    _getCoursesWithFiltering();
                  }
                  return false;
                },
                child: Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _getCoursesWithFiltering(reset: true);
                    },
                    child: ListView.separated(
                      padding: HWEdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      itemBuilder: (context, index) {
                        final item = courses[index];
                        return CourseCard(
                          height: 230,
                          title: item.name ?? '',
                          imageUrl: item.imageUrl ?? '',
                          chips: [
                            if (!(item.isFree ?? false))
                              CourseChipData(
                                '+${item.studentsCount ?? 0} طالب',
                                AppAssets.iconUser,
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            if (item.year?.name != null)
                              CourseChipData(
                                item.year!.name!,
                                AppAssets.iconLayers,
                                iconColor: AppColors.secondary,
                              ),
                            if (item.season?.name != null)
                              CourseChipData(
                                item.season!.name!,
                                AppAssets.iconDocument,
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                          ],
                          onTap: () {
                            context.push(
                              "${GRouter.config.applicationRoutes.courseDetails}/${item.id}",
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return 15.verticalSpace;
                      },
                      itemCount: courses.length,
                    ),
                  ),
                ),
              );
            },
          ),
          10.verticalSpace,
          BlocBuilder<CoursesBloc, CoursesState>(
            buildWhen: (p, c) =>
                p.coursesWithFiltering.paginationStatus !=
                c.coursesWithFiltering.paginationStatus,
            builder: (context, state) {
              final List<CourseModel> courses =
                  state.coursesWithFiltering.items
                      .firstWhereOrNull(
                        (item) => item.year?.id == widget.yearId,
                      )
                      ?.courses ??
                  [];
              if (courses.isNotEmpty && state.coursesWithFiltering.isLoading) {
                return Center(child: CoursatyAppLoader());
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
