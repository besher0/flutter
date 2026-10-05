import 'dart:developer';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/date_time.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/upsert_lecture_screen.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/teacher/course_details_section.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/lecture_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/common/constant/design/constant_design.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/extensions/build_context.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../course_content_management/presentation/bloc/course_content_management_bloc.dart';

class TeacherCourseDetailsPage extends StatefulWidget {
  const TeacherCourseDetailsPage({super.key, required this.courseId});

  final String courseId;

  @override
  State<TeacherCourseDetailsPage> createState() =>
      _TeacherCourseDetailsPageState();
}

class _TeacherCourseDetailsPageState extends State<TeacherCourseDetailsPage> {
  void _fetchDetails() {
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetTeacherCourseDetailsEvent(courseId: widget.courseId));
  }

  void _fetchStatistics() {
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCourseStatisticsEvent(courseId: widget.courseId));
  }

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "تفاصيل الكورس"),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              _CourseTabs(),
              BlocBuilder<CoursesBloc, CoursesState>(
                buildWhen: (p, c) =>
                    p.getTeacherCourseDetails != c.getTeacherCourseDetails,
                builder: (context, state) {
                  log(
                    'getTeacherCourseDetails ${state.getTeacherCourseDetails}',
                  );
                  if (state.getTeacherCourseDetails.isLoading ||
                      state.getTeacherCourseDetails.isInit) {
                    return Center(child: CoursatyAppLoader());
                  }
                  if (state.getTeacherCourseDetails.isFailed) {
                    return TryAgainWidget(
                      onPress: () {
                        _fetchDetails();
                      },
                    );
                  }
                  return Expanded(
                    child: TabBarView(
                      children: [
                        CourseDetailsSection(
                          courseDetailsModel:
                              state.teacherCourseDetailsResponseModel!,
                        ),
                        _LecturesTab(
                          onFailed: () {
                            _fetchDetails();
                          },
                          courseId: widget.courseId,
                        ),
                        _RevenueTab(
                          onFailed: () {
                            _fetchStatistics();
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
    );
  }
}

class _CourseTabs extends StatelessWidget {
  const _CourseTabs();

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: AppColors.secondary,
      labelColor: AppColors.secondary,
      unselectedLabelColor: AppColors.greyNormal,
      indicatorWeight: 2,
      labelStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
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
        Tab(text: 'تفاصيل'),
        Tab(text: 'المحاضرات'),
        Tab(text: 'ايرادات'),
      ],
    );
  }
}

class _LecturesTab extends StatelessWidget {
  const _LecturesTab({required this.onFailed, required this.courseId});

  final Function() onFailed;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      buildWhen: (p, c) =>
          p.teacherCourseDetailsResponseModel !=
          c.teacherCourseDetailsResponseModel,
      builder: (context, state) {
        if (state.getTeacherCourseDetails.isLoading) {
          return Center(child: CoursatyAppLoader());
        }
        if (state.getTeacherCourseDetails.isFailed) {
          return TryAgainWidget(
            onPress: () {
              onFailed.call();
            },
          );
        }
        return BlocConsumer<
          CourseContentManagementBloc,
          CourseContentManagementState
        >(
          listenWhen: (p, c) =>
              p.deleteFromCourseTransaction != c.deleteFromCourseTransaction,
          buildWhen: (p, c) =>
              p.deleteFromCourseTransaction != c.deleteFromCourseTransaction,
          listener: (context, state) {
            if (state.deleteFromCourseTransaction.isFailed) {
              showMessage(state.errorMessage);
            }
          },
          builder: (context, managementState) {
            return managementState.deleteFromCourseTransaction.isLoading
                ? Center(child: CoursatyAppLoader())
                : Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          onFailed.call();
                        },
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = 1;
                                const spacing = 10.0;
                                final width =
                                    (constraints.maxWidth -
                                        ((columns - 1) * spacing)) /
                                    columns;
                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: List.generate(
                                    state
                                            .teacherCourseDetailsResponseModel
                                            ?.lectures
                                            ?.length ??
                                        0,
                                    (i) {
                                      final lecture = state
                                          .teacherCourseDetailsResponseModel!
                                          .lectures![i];
                                      return SizedBox(
                                        width: width,
                                        height: 100,
                                        child: _LectureTile(
                                          index: i,
                                          lecture: lecture,
                                          courseId: courseId,
                                          onTap: () => context.push(
                                            "${GRouter.config.applicationRoutes.lectureDetailsForTeacher}/${lecture.id}/${lecture.title}/$courseId",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: FloatingActionButton(
                          onPressed: () {
                            context.pushPage(
                              AddOrUpdateLectureScreen(courseId: courseId),
                            );
                          },
                          child: Icon(Icons.add, color: AppColors.textLight),
                        ),
                      ),
                    ],
                  );
          },
        );
      },
    );
  }
}

class _LectureTile extends StatelessWidget {
  const _LectureTile({
    required this.index,
    required this.onTap,
    required this.lecture,
    required this.courseId,
  });

  final Lecture lecture;
  final int index;
  final VoidCallback onTap;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: LectureItem(
        index: index,
        lectureName: lecture.title!,
        // onDelete: () {
        //   BlocProvider.of<CourseContentManagementBloc>(context).add(
        //     DeleteLectureEvent(
        //       DeleteFromCourseParams(
        //         id: lecture.id!,
        //         endpoint: EndPoints.createLecture,
        //       ),
        //       courseId: courseId,
        //     ),
        //   );
        // },
        onEdit: () {
          context.pushPage(
            AddOrUpdateLectureScreen(courseId: courseId, lecture: lecture),
          );
        },
      ),
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab({required this.onFailed});

  final Function() onFailed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      buildWhen: (p, c) => p.getCourseStatistics != c.getCourseStatistics,
      builder: (context, state) {
        if (state.getCourseStatistics.isLoading) {
          return Center(child: CoursatyAppLoader());
        }
        if (state.getCourseStatistics.isFailed) {
          return TryAgainWidget(
            onPress: () {
              onFailed.call();
            },
          );
        }
        final stats = state.courseStatisticsModel!;
        return Container(
          height: 0.7.sh,
          padding: HWEdgeInsets.symmetric(horizontal: 15, vertical: 25),
          margin: HWEdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 0.2.sh,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kr12),
            border: Border(
              right: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              onFailed.call();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    'موجز عن إيرادات الكورس',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  _RevenueRow(
                    'تاريخ نشر الكورس',
                    '${stats.course?.publishedAt?.dmy}',
                  ),
                  if (stats.course?.expiresAt != null)
                    _RevenueRow(
                      'تاريخ إنتهاء الكورس',
                      stats.course!.expiresAt!.dmy,
                    ),
                  _RevenueRow(
                    'سعر الاشتراك',
                    '${stats.subscriptionPrice?.afterDiscount ?? 0}ل.س ',
                  ),
                  _RevenueRow(
                    'عدد المشتركين',
                    '${stats.subscriptions?.count ?? 0}',
                  ),
                  _RevenueRow(
                    'التقييم',
                    '(${stats.rating?.ratersCount ?? 0}) ${stats.rating?.average ?? 0} ☆',
                  ),
                  _RevenueRow(
                    'إيرادات قبل النسبة',
                    '${stats.revenue?.beforePercentage}ل.س ',
                  ),
                  _RevenueRow(
                    'إيرادات بعد النسبة',
                    '${stats.revenue?.afterPercentage}ل.س ',
                  ),
                  _RevenueRow(
                    'نسبتي',
                    '${stats.percentages?.teacherPercentage ?? 0}%',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RevenueRow extends StatelessWidget {
  const _RevenueRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          10.horizontalSpace,
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.greyNormal,
            ),
          ),
        ],
      ),
    );
  }
}
