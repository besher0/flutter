import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/course_card.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/empty_courses.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/widgets/search_with_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../teachers/presentation/widgets/teachers_grid.dart';
import '../bloc/home_bloc.dart';
import '../widgets/subject_card.dart';

class SearchPageContent extends StatefulWidget {
  const SearchPageContent({super.key});

  @override
  State<SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<SearchPageContent> {
  final TextEditingController controller = TextEditingController();

  Future<void> _fetchData() async {
    if (controller.text.length > 3) {
      BlocProvider.of<HomeBloc>(
        context,
      ).add(SearchEvent(query: controller.text));
    }
  }

  @override
  void dispose() {
    BlocProvider.of<HomeBloc>(context).add(ClearSearchResultsEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          15.verticalSpace,
          SearchWithFilterBar(controller: controller),
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
              Tab(text: 'كورسات'),
              Tab(text: 'مواد'),
              Tab(text: 'برامج'),
              Tab(text: 'أساتذة'),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Content
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (p, c) =>
                  p.courses.paginationStatus != c.courses.paginationStatus,
              builder: (context, state) {
                if (state.courses.isFailure) {
                  return TryAgainWidget(
                    onPress: () {
                      BlocProvider.of<HomeBloc>(
                        context,
                      ).add(SearchEvent(query: controller.text));
                    },
                  );
                }
                return TabBarView(
                  children: [
                    state.courses.isInitial
                        ? Center(
                            child: Text(
                              "ابحث عن كورس...",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : state.courses.isLoading
                        ? Center(child: CoursatyAppLoader())
                        : state.courses.items.isEmpty && state.courses.isSuccess
                        ? EmptyCourses()
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                  (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                                _fetchData();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              onRefresh: _fetchData,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final item = state.courses.items[index];
                                  return CourseCard(
                                    title: item.name ?? '',
                                    imageUrl: item.imageUrl ?? '',
                                    height: 230,
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
                                separatorBuilder: (context, index) =>
                                    15.verticalSpace,
                                itemCount: state.courses.items.length,
                              ),
                            ),
                          ),

                    state.courses.isInitial
                        ? Center(
                            child: Text(
                              "ابحث عن مادة...",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : state.courses.isLoading
                        ? Center(child: CoursatyAppLoader())
                        : state.subjects.isEmpty && state.courses.isSuccess
                        ? Center(
                            child: Text(
                              "لايوجد مواد",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchData,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              itemBuilder: (context, index) {
                                final s = state.subjects[index];
                                return SubjectCard(
                                  title: s.name ?? '',
                                  imageUrl: s.imageUrl ?? '',
                                  year: s.year?.name ?? '',
                                  semester: s.season?.name ?? '',
                                  onTap: () {
                                    context.push(
                                      "${GRouter.config.applicationRoutes.coursesBySubject}/${s.id}/true",
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  15.verticalSpace,
                              itemCount: state.subjects.length,
                            ),
                          ),
                    state.courses.isInitial
                        ? Center(
                            child: Text(
                              "ابحث عن برنامح...",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : state.courses.isLoading
                        ? Center(child: CoursatyAppLoader())
                        : state.programs.isEmpty && state.courses.isSuccess
                        ? Center(
                            child: Text(
                              "لايوجد برامج",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchData,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              itemBuilder: (context, index) {
                                final s = state.programs[index];
                                return SubjectCard(
                                  title: s.name ?? '',
                                  imageUrl: s.imageUrl ?? '',
                                  // teacher: s.teacher?.name,
                                  // year: s.year?.name ?? '',
                                  // semester: s.season?.name ?? '',
                                  onTap: () {
                                    context.push(
                                      "${GRouter.config.applicationRoutes.coursesBySubject}/${s.id}/true",
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  15.verticalSpace,
                              itemCount: state.programs.length,
                            ),
                          ),
                    state.courses.isInitial
                        ? Center(
                            child: Text(
                              "ابحث عن معلم...",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : state.courses.isLoading
                        ? Center(child: CoursatyAppLoader())
                        : state.teachers.isEmpty && state.courses.isSuccess
                        ? Center(
                            child: Text(
                              "لايوجد أساتذة",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchData,
                            child: TeachersGrid(teachers: state.teachers),
                          ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
