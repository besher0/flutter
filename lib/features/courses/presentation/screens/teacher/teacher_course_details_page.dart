import 'package:coursaty_student_and_teacher/core/common/constant/configuration/paid_content_policy.dart';
import 'dart:developer';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/revenue_widgets.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/date_time.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/upsert_lecture_screen.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
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
          length: PaidContentPolicy.hidePaid ? 2 : 3,
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
                        if (!PaidContentPolicy.hidePaid)
                          _RevenueTab(courseId: widget.courseId),
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
      tabs: [
        const Tab(text: 'تفاصيل'),
        const Tab(text: 'المحاضرات'),
        if (!PaidContentPolicy.hidePaid) const Tab(text: 'ايرادات'),
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

class _RevenueTab extends StatefulWidget {
  const _RevenueTab({required this.courseId});

  final String courseId;

  @override
  State<_RevenueTab> createState() => _RevenueTabState();
}

class _RevenueTabState extends State<_RevenueTab>
    with AutomaticKeepAliveClientMixin {
  RevenuePeriod _period = RevenuePeriod.allTime;

  @override
  bool get wantKeepAlive => true;

  void _load() {
    BlocProvider.of<CoursesBloc>(
      context,
    ).add(GetCourseStatisticsEvent(courseId: widget.courseId, period: _period));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: RevenuePeriodSelector(
            selected: _period,
            onChanged: (period) {
              setState(() => _period = period);
              _load();
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<CoursesBloc, CoursesState>(
            buildWhen: (p, c) => p.getCourseStatistics != c.getCourseStatistics,
            builder: (context, state) {
              final stats = state.courseStatisticsModel;
              if (state.getCourseStatistics.isLoading ||
                  state.getCourseStatistics.isInit) {
                return Center(child: CoursatyAppLoader());
              }
              if (state.getCourseStatistics.isFailed || stats == null) {
                return Center(child: TryAgainWidget(onPress: _load));
              }
              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: _CourseRevenueReport(stats: stats, period: _period),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseRevenueReport extends StatelessWidget {
  const _CourseRevenueReport({required this.stats, required this.period});

  final CourseStatisticsModel stats;
  final RevenuePeriod period;

  @override
  Widget build(BuildContext context) {
    final summary = stats.summary;
    final courseInvoice = stats.courseInvoice;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        RevenueHeroCard(
          title: 'أرباحك من الكورس · ${period.label}',
          amount: summary.teacherRevenue,
          footer: [
            Text('من مبيعات ${formatMoney(summary.totalRevenues)}'),
            Text('نسبتك الحالية ${formatPercent(stats.myPercentage)}'),
          ],
        ),
        const SizedBox(height: 12),
        if (summary.subscriptions == 0)
          RevenueSection(
            title: 'ملخص الفترة',
            child: RevenueEmptyPeriod(period: period),
          )
        else ...[
          RevenueStatGrid(
            stats: [
              RevenueStat(
                'الاشتراكات',
                formatCount(summary.subscriptions),
                Icons.how_to_reg_outlined,
                hint:
                    '${formatCount(summary.initialSubscriptions)} جديد · ${formatCount(summary.renewals)} تجديد',
              ),
              RevenueStat(
                'الطلاب',
                formatCount(summary.uniqueStudents),
                Icons.groups_outlined,
              ),
              RevenueStat(
                'متوسط الاشتراك',
                formatMoney(summary.averagePerSubscription),
                Icons.trending_up,
                hint: 'المدفوع لكل اشتراك',
              ),
              RevenueStat(
                'الخصومات الممنوحة',
                formatMoney(summary.totalDiscount),
                Icons.local_offer_outlined,
                hint:
                    'كورس ${formatMoney(summary.courseDiscount)} · أكواد ${formatMoney(summary.codeDiscount)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          RevenueSection(
            title: 'كيف حُسبت أرباحك',
            child: RevenueBreakdown(summary: summary),
          ),
          if (stats.invoice.monthly.length > 1) ...[
            const SizedBox(height: 12),
            RevenueSection(
              title: 'أرباحك حسب الشهر',
              subtitle: 'آخر ستة أشهر فيها اشتراكات',
              child: RevenueMonthlyBars(
                months: stats.invoice.monthly,
                valueOf: (month) => month.teacherRevenue,
              ),
            ),
          ],
          if (courseInvoice != null && courseInvoice.lineItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            RevenueSection(
              title: 'الاشتراكات حسب السعر',
              child: RevenueLineItemsList(lineItems: courseInvoice.lineItems),
            ),
          ],
          if (courseInvoice != null && courseInvoice.codeGroups.isNotEmpty) ...[
            const SizedBox(height: 12),
            RevenueSection(
              title: 'مصادر الاشتراك',
              subtitle: 'دفعات الأكواد وإيصالات الدفع',
              child: RevenueCodeGroupsList(
                codeGroups: courseInvoice.codeGroups,
              ),
            ),
          ],
        ],
        const SizedBox(height: 12),
        RevenueSection(
          title: 'معلومات الكورس',
          child: Column(
            children: [
              if (stats.isPriceVisible) ...[
                RevenueRow(
                  'سعر الاشتراك الحالي',
                  formatMoney(stats.priceAfterDiscount),
                ),
                if (stats.discountPercentage > 0)
                  RevenueRow(
                    'قبل الخصم',
                    '${formatMoney(stats.priceBeforeDiscount)} (خصم ${formatPercent(stats.discountPercentage)})',
                  ),
              ] else
                RevenueRow('سعر الاشتراك', 'مخفي عن الطلاب'),
              RevenueRow(
                'التقييم',
                stats.ratersCount == 0
                    ? 'لا تقييمات بعد'
                    : '★ ${stats.ratingAverage.toStringAsFixed(1)} من ${formatCount(stats.ratersCount)} تقييم',
              ),
              if (stats.publishedAt != null)
                RevenueRow('تاريخ النشر', stats.publishedAt!.toLocal().dmy),
              if (stats.expiresAt != null)
                RevenueRow('تاريخ الانتهاء', stats.expiresAt!.toLocal().dmy),
            ],
          ),
        ),
      ],
    );
  }
}
