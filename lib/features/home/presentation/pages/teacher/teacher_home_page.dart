import 'package:coursaty_student_and_teacher/app/widgets/adaptive_card_row.dart';
import 'package:coursaty_student_and_teacher/core/platform/app_layout.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/paid_content_policy.dart';
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
import '../../widgets/home_skeletons.dart';

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
          // Skeleton only for the first load; a refresh keeps the cards.
          final hasSummary = state.teacherSummaryResponseModel != null;
          if (state.getTeacherSummary.isInit ||
              (state.getTeacherSummary.isLoading && !hasSummary)) {
            return TeacherHomeSkeleton(
              showEarnings: !PaidContentPolicy.hidePaid,
            );
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
                if (!PaidContentPolicy.hidePaid) ...[
                  RevenueHeroCard(
                    monthName: state.teacherSummaryResponseModel!.monthNumber
                        .toString(),
                    total: state.teacherSummaryResponseModel!.monthlyEarnings
                        .toString(),
                  ),
                  const SizedBox(height: 12),
                ],
                _metrics(state),
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
                  AdaptiveCardRow(
                    height: 200.h,
                    itemCount:
                        state.teacherSummaryResponseModel?.courses?.length ?? 0,
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
                              iconColor: Theme.of(context).colorScheme.primary,
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
                    child: HorizontalMouseDrag(
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
                            width: AppLayout.listCardWidth(0.85.sw),
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
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Two rows of two on the phone; one row of four on a wide desktop window.
  Widget _metrics(HomeState state) {
    final summary = state.teacherSummaryResponseModel!;
    final cards = [
      SmallMetricCard(
        value: "⭐${(summary.averageCourseRating ?? 0).toStringAsFixed(2)}",
        label: 'معدل تقييم الكورسات',
        amber: true,
      ),
      SmallMetricCard(
        value: '${summary.coursesCount ?? 0}',
        label: 'عدد الكورسات الإجمالي',
      ),
      SmallMetricCard(
        value: '${summary.likesCount ?? 0}',
        label: 'عدد اللايكات الإجمالي',
      ),
      SmallMetricCard(
        value: '${summary.studentsCount ?? 0}',
        label: 'عدد الطلاب الإجمالي',
        amber: true,
      ),
    ];
    Widget row(List<Widget> items) => Row(
      spacing: 10,
      children: [for (final card in items) Expanded(child: card)],
    );
    if (AppLayout.isWide(context)) return row(cards);
    return Column(
      spacing: 10,
      children: [row(cards.sublist(0, 2)), row(cards.sublist(2))],
    );
  }

  void _getHomeData() {
    BlocProvider.of<HomeBloc>(context).add(GetTeacherSummaryEvent());
  }
}
