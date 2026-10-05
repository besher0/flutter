import 'dart:math';

import 'package:coursaty_student_and_teacher/features/home/presentation/pages/search_page.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/presentation/bloc/sales_points_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/app_drawer.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/common/constant/configuration/feature_flags.dart';
import '../../../sales_points/presentation/widgets/point_of_sale_card.dart';
import '../bloc/home_bloc.dart';
import '../widgets/banner_carousel.dart';

import '../widgets/section_card.dart';
import '../widgets/section_header.dart';
import '../widgets/teacher_avatar_name.dart';
import '../widgets/home_app_bar.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.openSearch});

  final ValueNotifier<bool> openSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onBellTap: () {
          context.push(GRouter.config.applicationRoutes.notifications);
        },
        onSearch: () {
          openSearch.value = true;
        },
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: openSearch,
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (p, c) => p.getHomeContent != c.getHomeContent,
            builder: (context, state) {
              if (state.getHomeContent.isLoading) {
                return Center(child: CoursatyAppLoader());
              }
              final banners = state.homeResponseModel?.advertisements ?? [];
              final teachers = state.homeResponseModel?.teachers ?? [];
              final programs = state.homeResponseModel?.programs ?? [];
              final subjects = state.homeResponseModel?.subjects ?? [];
              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<HomeBloc>(context).add(GetHomeContentEvent());
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banners.isNotEmpty) ...{
                        10.verticalSpace,
                        BannerCarousel(height: 158, banners: banners),
                        const SizedBox(height: 12),
                      },
                      if (teachers.isNotEmpty) ...{
                        SectionHeader(
                          title: 'الأساتذة',
                          onMoreTap: () => _goToTeachers(context),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: teachers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final teacher = teachers[i];
                              return TeacherAvatarName(
                                name: teacher.name ?? '',
                                imageUrl: teacher.image ?? '',
                                onTap: () {
                                  context.push(
                                    '${GRouter.config.applicationRoutes.teacherDetails}/${teacher.id}/${teacher.name}',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      },
                      if (subjects.isNotEmpty) ...{
                        SectionHeader(
                          title: 'المواد',
                          onMoreTap: () {
                            context.push(
                              GRouter.config.applicationRoutes.materials,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: subjects.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 20),
                            itemBuilder: (context, i) => SectionCard(
                              subject: subjects[i],
                              onTap: () {
                                context.push(
                                  '${GRouter.config.applicationRoutes.coursesBySubject}/${subjects[i].id}/true',
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      },
                      if (programs.isNotEmpty) ...{
                        SectionHeader(
                          title: 'البرامج',
                          onMoreTap: () {
                            context.push(
                              GRouter.config.applicationRoutes.allPrograms,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: programs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 20),
                            itemBuilder: (context, i) => SectionCard(
                              subject: programs[i],
                              onTap: () {
                                context.push(
                                  '${GRouter.config.applicationRoutes.coursesBySubject}/${programs[i].id}/false',
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      },
                      if (SubscriptionFeatureFlags
                          .showLegacySubscriptionMethods)
                        BlocBuilder<SalesPointsBloc, SalesPointsState>(
                          buildWhen: (p, c) =>
                              p.getSalesPointsStatus != c.getSalesPointsStatus,
                          builder: (context, state) {
                            return state.getSalesPointsStatus.isLoading
                                ? Center(child: CoursatyAppLoader())
                                : state.salesPoints.isEmpty
                                ? SizedBox.shrink()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SectionHeader(
                                        title: 'نقاط البيع',
                                        onMoreTap: () {
                                          context.push(
                                            GRouter
                                                .config
                                                .applicationRoutes
                                                .pointsOfSale,
                                          );
                                        },
                                      ),
                                      20.verticalSpace,
                                      SizedBox(
                                        height: 140,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: min(
                                            3,
                                            state.salesPoints.length,
                                          ),
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 20),
                                          itemBuilder: (context, i) =>
                                              PointOfSaleCard(
                                                salePoint: state.salesPoints[i],
                                              ),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
          builder: (context, open, child) {
            return open ? SearchPageContent() : child!;
          },
        ),
      ),
    );
  }

  void _goToTeachers(BuildContext context) {
    context.push(GRouter.config.applicationRoutes.teachers);
  }
}
