import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../../core/common/constant/design/app_assets.dart';
import '../../../../../core/routes/router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/extensions/list_extensions.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../home/presentation/widgets/section_header.dart';
import '../../widgets/course_card.dart';
import '../../widgets/empty_courses.dart';

class TeacherCoursesPage extends StatefulWidget {
  const TeacherCoursesPage({super.key});

  @override
  State<TeacherCoursesPage> createState() => _TeacherCoursesPageState();
}

class _TeacherCoursesPageState extends State<TeacherCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(GRouter.config.applicationRoutes.selectSubject);
        },
        child: Icon(Icons.add, color: AppColors.textLight),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.secondary,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.greyNormal,
              indicatorWeight: 2,
              labelStyle: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              dividerColor: Theme.of(context).colorScheme.surface,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
                insets: const EdgeInsets.symmetric(horizontal: 40),
              ),
              tabs: const [
                Tab(text: 'الفعالة'),
                Tab(text: 'المنتهية'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _TabBarViewItem(forActive: true),
                  _TabBarViewItem(forActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarViewItem extends StatelessWidget {
  const _TabBarViewItem({required this.forActive});

  final bool forActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                (0.7 * scrollInfo.metrics.maxScrollExtent)) {
              BlocProvider.of<CoursesBloc>(
                context,
              ).add(GetTeacherCourses(getActive: forActive));
            }
            return false;
          },
          child: BlocBuilder<CoursesBloc, CoursesState>(
            buildWhen: (p, c) =>
                (p.teacherActiveCourses.paginationStatus !=
                        c.teacherActiveCourses.paginationStatus &&
                    forActive) ||
                (p.teacherExpiredCourses.paginationStatus !=
                        c.teacherExpiredCourses.paginationStatus &&
                    !forActive),
            builder: (context, state) {
              {
                if ((state.teacherActiveCourses.items.isEmpty &&
                        state.teacherActiveCourses.isLoading &&
                        forActive) ||
                    (state.teacherExpiredCourses.items.isEmpty &&
                        state.teacherExpiredCourses.isLoading &&
                        !forActive)) {
                  return Center(child: CoursatyAppLoader());
                }
                final years =
                    (forActive
                            ? state.teacherActiveCourses.items
                            : state.teacherExpiredCourses.items)
                        .firstOrNull
                        ?.years ??
                    [];
                years.removeWhere((item) => item.courses.isNullOrEmpty);
                if (years.isEmpty) {
                  return Expanded(child: EmptyCourses());
                }
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<CoursesBloc>(context).add(
                        GetTeacherCourses(getActive: forActive, reset: true),
                      );
                    },
                    child: ListView.builder(
                      itemCount: years.length,
                      shrinkWrap: true,
                      padding: HWEdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SectionHeader(
                              title: years[index].year?.name ?? '',
                              showMore: false,
                              color: AppColors.text,
                            ),
                            SizedBox(
                              height: 260,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: years[index].courses?.length ?? 0,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, i) {
                                  final item = years[index].courses![i];
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
                                      if (years[index].year?.name != null)
                                        CourseChipData(
                                          years[index].year!.name!,
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
                                        "${GRouter.config.applicationRoutes.teacherCourseDetails}/${item.id}",
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
        10.verticalSpace,
        BlocBuilder<CoursesBloc, CoursesState>(
          buildWhen: (p, c) =>
              (p.teacherActiveCourses.paginationStatus !=
                      c.teacherActiveCourses.paginationStatus &&
                  forActive) ||
              (p.teacherExpiredCourses.paginationStatus !=
                      c.teacherExpiredCourses.paginationStatus &&
                  !forActive),
          builder: (context, state) {
            if ((state.teacherActiveCourses.items.isNotEmpty &&
                    state.teacherActiveCourses.isLoading &&
                    forActive) ||
                (state.teacherExpiredCourses.items.isNotEmpty &&
                    state.teacherExpiredCourses.isLoading &&
                    !forActive)) {
              return Center(child: CoursatyAppLoader());
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
