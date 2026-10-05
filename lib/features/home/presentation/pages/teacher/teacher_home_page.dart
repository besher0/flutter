import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/list_extensions.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/teacher/widgets/metric_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/common/constant/design/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../courses/presentation/widgets/course_card.dart';
import '../../../../norifications/presentation/widgets/notification_tile.dart';
import '../../widgets/section_header.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key, required this.goToCourses});

  final Function() goToCourses;

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getTeacherSummary != c.getTeacherSummary ||
            p.counterToForceUpdate != c.counterToForceUpdate,
        builder: (context, state) {
          if (state.getTeacherSummary.isLoading ||
              state.getTeacherSummary.isInit) {
            return Center(child: CoursatyAppLoader());
          }
          if (state.getTeacherSummary.isFailed) {
            return TryAgainWidget(
              onPress: () {
                _getHomeData();
              },
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              _getHomeData();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RevenueHeroCard(
                  monthName: state.teacherSummaryResponseModel!.monthNumber
                      .toString(),
                  total: state.teacherSummaryResponseModel!.monthlyEarnings
                      .toString(),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SmallMetricCard(
                            value:
                                "⭐${(state.teacherSummaryResponseModel!.averageCourseRating ?? 0).toStringAsFixed(2)}",
                            label: 'معدل تقييم الكورسات',
                            amber: true,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: SmallMetricCard(
                            value:
                                '${state.teacherSummaryResponseModel!.coursesCount ?? 0}',
                            label: 'عدد الكورسات الإجمالي',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SmallMetricCard(
                            value:
                                '${state.teacherSummaryResponseModel!.likesCount ?? 0}',
                            label: 'عدد اللايكات الإجمالي',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: SmallMetricCard(
                            value:
                                '${state.teacherSummaryResponseModel!.studentsCount ?? 0}',
                            label: 'عدد الطلاب الإجمالي',
                            amber: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!(state
                        .teacherSummaryResponseModel
                        ?.courses
                        ?.isNullOrEmpty ??
                    true)) ...{
                  const SizedBox(height: 14),
                  SectionHeader(
                    title: 'كورساتي قيد المعالجة',
                    onMoreTap: () {
                      widget.goToCourses();
                    },
                    showMore: false,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200.h,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          state.teacherSummaryResponseModel?.courses?.length ??
                          0,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final item =
                            state.teacherSummaryResponseModel!.courses![i];
                        return CourseCard(
                          title: item.name ?? '',
                          imageUrl: item.imageUrl ?? '',
                          chips: [
                            CourseChipData(
                              '+${item.studentsCount ?? 0} طالب',
                              AppAssets.iconUser,
                              iconColor: Theme.of(context).colorScheme.primary,
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
                            CourseChipData(
                              "${item.duration} ساعة",
                              AppAssets.iconTimer,
                              iconColor: AppColors.secondary,
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
                },
                if (!(state
                        .teacherSummaryResponseModel
                        ?.pendingNotifications
                        ?.isNullOrEmpty ??
                    true)) ...[
                  const SizedBox(height: 8),
                  SectionHeader(
                    title: "إشعارات قيد المعالجة",
                    showMore: false,
                    onMoreTap: () {
                      context.push(
                        GRouter.config.applicationRoutes.notifications,
                      );
                    },
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          state
                              .teacherSummaryResponseModel
                              ?.pendingNotifications
                              ?.length ??
                          0,
                      shrinkWrap: true,
                      separatorBuilder: (_, __) => 10.horizontalSpace,
                      itemBuilder: (context, i) {
                        return SizedBox(
                          width: 0.85.sw,
                          child: NotificationTile(
                            item: state
                                .teacherSummaryResponseModel!
                                .pendingNotifications![i],
                            fromTeacher: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _getHomeData() {
    BlocProvider.of<HomeBloc>(context).add(GetTeacherSummaryEvent());
  }
}
