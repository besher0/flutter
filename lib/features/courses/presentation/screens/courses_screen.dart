import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/list_extensions.dart';
import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/more_courses_page.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:injectable_generator/utils.dart';

import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../widgets/empty_courses.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, required this.currentSelectedCategory});

  final ValueNotifier<String> currentSelectedCategory;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  void _getCoursesWithFiltering({bool reset = false}) {
    final selected = widget.currentSelectedCategory.value;
    bool sendFilter = ['all', 'popular', "free"].contains(selected);
    BlocProvider.of<CoursesBloc>(context).add(
      GetCoursesWithFilteringEvent(
        filter: sendFilter ? selected : null,
        categoryId: !sendFilter ? selected : null,
        reset: reset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(title: 'الكورسات'),
        body: SafeArea(
          child: Column(
            children: [
              15.verticalSpace,
              ValueListenableBuilder(
                valueListenable: widget.currentSelectedCategory,
                builder: (context, selected, child) {
                  return BlocBuilder<CoursesBloc, CoursesState>(
                    builder: (context, state) {
                      return Wrap(
                        runSpacing: 15,
                        children: List.generate(
                          state.coursesCategories.length,
                          (index) {
                            final category = state.coursesCategories[index];
                            final isSelected = selected == category.id;
                            return Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                onTap: () {
                                  widget.currentSelectedCategory.value =
                                      category.id!;
                                  _getCoursesWithFiltering(reset: true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.chipBackground,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    category.name!,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              20.verticalSpace,
              Expanded(
                child: RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  onRefresh: () async {
                    _getCoursesWithFiltering(reset: true);
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        BlocBuilder<CoursesBloc, CoursesState>(
                          buildWhen: (p, c) =>
                              p.coursesWithFiltering.paginationStatus !=
                              c.coursesWithFiltering.paginationStatus,
                          builder: (context, state) {
                            if (state.coursesWithFiltering.isFailure) {
                              return SizedBox(
                                height: 1.sh - 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TryAgainWidget(
                                      onPress: _getCoursesWithFiltering,
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (state.coursesWithFiltering.items.isEmpty &&
                                state.coursesWithFiltering.isLoading) {
                              return SizedBox(
                                height: 1.sh - 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [CoursatyAppLoader()],
                                ),
                              );
                            }
                            List<YearElement> years = List.of(
                              state.coursesWithFiltering.items,
                            );
                            int yearsCount = 0;
                            bool isTherePrograms = false;
                            years.removeWhere(
                              (item) => item.courses.isNullOrEmpty,
                            );
                            yearsCount = years.length;
                            years.removeWhere((item) => item.year == null);
                            years.removeWhere((item) => item.year?.id == null);
                            isTherePrograms = years.length != yearsCount;
                            if (years.isEmpty && !isTherePrograms) {
                              return SizedBox(
                                height: 1.sh - 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [EmptyCourses()],
                                ),
                              );
                            }
                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: years.length,
                              padding: HWEdgeInsets.only(left: 15, right: 15),
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SectionHeader(
                                      title: years[index].year!.name!,
                                      onMoreTap: () {
                                        final category = widget
                                            .currentSelectedCategory
                                            .value;
                                        final sendFilter = [
                                          'all',
                                          'popular',
                                          "free",
                                        ].contains(category);
                                        context.pushPage(
                                          MoreCoursesPage(
                                            categoryId: !sendFilter
                                                ? category
                                                : null,
                                            filter: sendFilter
                                                ? category
                                                : null,
                                            yearId: years[index].year!.id!,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 230,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            years[index].courses?.length ?? 0,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (_, i) {
                                          final item = years[index].courses![i];
                                          return CourseCard(
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
                                                  iconColor:
                                                      AppColors.secondary,
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
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        10.verticalSpace,
                        BlocBuilder<CoursesBloc, CoursesState>(
                          buildWhen: (p, c) =>
                              p.coursesWithFiltering.paginationStatus !=
                              c.coursesWithFiltering.paginationStatus,
                          builder: (context, state) {
                            if (state.coursesWithFiltering.items.isEmpty &&
                                state.coursesWithFiltering.isLoading) {
                              return SizedBox.shrink();
                            }
                            List<CourseModel> programCourses = List.of(
                              state.coursesWithFiltering.items
                                      .firstWhereOrNull(
                                        (item) => item.year?.id == null,
                                      )
                                      ?.courses ??
                                  [],
                            );
                            if (programCourses.isEmpty) {
                              return SizedBox.shrink();
                            }
                            return Padding(
                              padding: HWEdgeInsets.only(left: 15, right: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SectionHeader(
                                    title: "برامج",
                                    showMore: false,
                                  ),
                                  ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 15,
                                    ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: programCourses.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (_, i) {
                                      final item = programCourses[i];
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
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
