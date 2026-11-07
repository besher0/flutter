import 'package:coursaty_student_and_teacher/core/common/constant/configuration/paid_content_policy.dart';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/subscription_interests_tab.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/date_time.dart';
import '../../../../app/widgets/skeleton/skeleton.dart';
import '../widgets/home_skeletons.dart';
import '../../../../app/widgets/loading_indicator/inline_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/interaction/app_pressable.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  void _onBellTap() {
    context.push(GRouter.config.applicationRoutes.notifications);
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(DeleteOutDatedCoursesEvent());
    BlocProvider.of<SubscriptionBloc>(context).add(LoadCourseInterests());
  }

  /// Pull-to-refresh in any tab reloads every tab (each shows its skeleton
  /// until its own list arrives).
  Future<void> _refreshAll() async {
    BlocProvider.of<HomeBloc>(context)
      ..add(GetMyActiveCourses())
      ..add(GetMyInActiveCourses());
    if (!PaidContentPolicy.hidePaid) {
      BlocProvider.of<SubscriptionBloc>(context).add(LoadCourseInterests());
    }
  }

  Widget _tab({
    required bool loading,
    required bool failed,
    required bool deleting,
    required List<CourseModel> courses,
    required bool isExpired,
  }) {
    if (loading) return const SubscriptionListSkeleton();
    if (courses.isEmpty) {
      return _RefreshableMessage(
        onRefresh: _refreshAll,
        child: failed
            ? TryAgainWidget(onPress: _refreshAll)
            : const _EmptySubscriptionsState(),
      );
    }
    // Removing outdated courses keeps the list, blocked, with a thin bar.
    return BusyOverlay(
      busy: deleting,
      child: _SubscriptionsList(
        courses: courses,
        isExpired: isExpired,
        onRefresh: _refreshAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: 'اشتراكاتي', onBellTap: _onBellTap),
      body: SafeArea(
        child: DefaultTabController(
          // The purchase-requests tab is a payment flow: hidden on an iPhone
          // whose admin setting hides paid content.
          length: PaidContentPolicy.hidePaid ? 2 : 3,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ✅ Tabs
              TabBar(
                onTap: (_) => tabTapHaptic(context),
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
                tabs: [
                  if (!PaidContentPolicy.hidePaid) const Tab(text: 'اهتماماتي'),
                  const Tab(text: 'الفعالة'),
                  const Tab(text: 'المنتهية'),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Content
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) =>
                      p.isDeleting != c.isDeleting ||
                      p.getActiveCourses != c.getActiveCourses ||
                      p.getInActiveCourses != c.getInActiveCourses,
                  builder: (context, state) {
                    return TabBarView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        if (!PaidContentPolicy.hidePaid)
                          InterestsTab(onRefresh: _refreshAll),
                        // ✅ Active Tab (skeleton while it loads, also on
                        // refresh)
                        _tab(
                          loading: state.getActiveCourses.isLoading,
                          failed: state.getActiveCourses.isFailed,
                          deleting: state.isDeleting,
                          courses: state.activeCourses,
                          isExpired: false,
                        ),

                        // ✅ Expired Tab
                        _tab(
                          loading: state.getInActiveCourses.isLoading,
                          failed: state.getInActiveCourses.isFailed,
                          deleting: state.isDeleting,
                          courses: state.inActiveCourses,
                          isExpired: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionsList extends StatelessWidget {
  const _SubscriptionsList({
    required this.courses,
    required this.isExpired,
    required this.onRefresh,
  });

  final List<CourseModel> courses;
  final bool isExpired;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      // Fills the tab and always scrolls, so pull-to-refresh works with
      // only one or two courses too.
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final s = courses[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SubscriptionCard(
              onTap: () {
                if (isExpired) {
                  showMessage("هذا الكورس منتهي لم يعد بإمكانك الوصول لمحتواه");
                  return;
                }
                context.push(
                  "${GRouter.config.applicationRoutes.courseDetails}/${s.id}",
                );
              },
              item: _SubscriptionItem(
                title: s.name ?? '',
                ratingText: (s.rating ?? 0).toString(),
                semester: s.season?.name,
                yearText: s.collegeYear?.academicYear?.yearName,
                mentorText: s.teacher?.name,
                subscribedAtText: s.subscribedAt?.dmy,
                expiresAtText: s.subscriptionExpiresAt?.dmy,
                expiredCoverUrl: s.imageUrl ?? '',
                activeCoverUrl: s.imageUrl ?? '',
              ),
              isExpired: isExpired,
            ),
          );
        },
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.item,
    required this.isExpired,
    required this.onTap,
  });

  final _SubscriptionItem item;
  final bool isExpired;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final coverUrl = isExpired ? item.expiredCoverUrl : item.activeCoverUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightTrack),
          boxShadow: [AppColors.cardShadow],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: coverUrl,
                    height: 83,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ImageSkeleton(height: 83, width: double.infinity),
                    errorWidget: (_, __, ___) => Container(
                      height: 83,
                      color: AppColors.primaryLightTrack,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
                if (isExpired)
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                if (isExpired)
                  Positioned(
                    bottom: 83 / 2,
                    right: (1.sw - 120) / 2,
                    child: Text(
                      'منتهية',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF9F9F9),
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isExpired
                    ? const Color(0xFF777777)
                    : Theme.of(context).colorScheme.onSurface,
                height: 1.4,
                decoration: isExpired
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  if (item.yearText != null)
                    _CourseChip(
                      text: item.yearText!,
                      iconAssetPath: AppAssets.iconLayers,
                      iconSize: 11,
                    ),
                  if (item.mentorText != null)
                    _CourseChip(
                      text: item.mentorText!,
                      iconAssetPath: AppAssets.iconUser,
                      iconSize: 11,
                    ),
                  _CourseChipRating(ratingText: item.ratingText),
                  if (item.semester != null)
                    _CourseChip(
                      text: item.semester!,
                      iconAssetPath: AppAssets.iconLayers,
                      iconSize: 11,
                    ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (item.subscribedAtText != null)
                  Flexible(
                    child: Text(
                      "تاريخ الاشتراك: ${item.subscribedAtText!}",
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF39AC27),
                        height: 1.4,
                        decoration: isExpired
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                const SizedBox(width: 20),
                if (item.expiresAtText != null)
                  Flexible(
                    child: Text(
                      "تاريخ الانتهاء ${item.expiresAtText!}",
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC61F1F),
                        height: 1.4,
                        decoration: isExpired
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseChip extends StatelessWidget {
  const _CourseChip({
    required this.text,
    required this.iconAssetPath,
    required this.iconSize,
  });

  final String text;
  final String iconAssetPath;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.085, vertical: 4.043),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(11.117),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 10.09,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0E2D2E),
              height: 1.4,
            ),
          ),
          const SizedBox(width: 5),
          SvgPicture.asset(
            iconAssetPath,
            height: iconSize,
            color: const Color(0xFF0E2D2E),
          ),
        ],
      ),
    );
  }
}

class _CourseChipRating extends StatelessWidget {
  const _CourseChipRating({required this.ratingText});

  final String ratingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.085, vertical: 4.043),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(11.117),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ratingText,
            style: GoogleFonts.cairo(
              fontSize: 10.09,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0E2D2E),
              height: 1.4,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.star_rounded, size: 11, color: AppColors.secondary),
        ],
      ),
    );
  }
}

/// Pull-to-refresh for a tab whose content is not a list (empty / failed).
class _RefreshableMessage extends StatelessWidget {
  const _RefreshableMessage({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _EmptySubscriptionsState extends StatelessWidget {
  const _EmptySubscriptionsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.primaryLightTrack,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconDocument,
                height: 28,
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد اشتراكات',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionItem {
  const _SubscriptionItem({
    required this.title,
    required this.ratingText,
    this.semester,
    this.yearText,
    this.mentorText,
    this.subscribedAtText,
    this.expiresAtText,
    required this.expiredCoverUrl,
    required this.activeCoverUrl,
  });

  final String title;
  final String ratingText;
  final String? semester;
  final String? yearText;
  final String? mentorText;
  final String? subscribedAtText;
  final String? expiresAtText;
  final String expiredCoverUrl;
  final String activeCoverUrl;
}
