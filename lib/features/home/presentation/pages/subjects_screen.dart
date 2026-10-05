import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/filtered_subjects_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/widgets/subject_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  int _selectedYearIndex = 0;

  int? _selectedSeasonIndex;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<HomeBloc>(context).add(GetSubjectsWithFilteringEvent());
  }

  Future<void> _refresh() async {
    BlocProvider.of<HomeBloc>(context).add(GetSubjectsWithFilteringEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TitleAppBar(
        title: 'المواد',
        onBackTap: () {
          context.pop();
        },
      ),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.getSubjectsWithFiltering.isLoading) {
              return Center(child: CoursatyAppLoader());
            }

            final StudentSubjectsModel? model = state.studentSubjectsModel;

            final List<Year> years = model?.years ?? [];

            if (years.isEmpty) {
              return Center(
                child: Text(
                  "لايوجد مواد",
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            if (_selectedYearIndex >= years.length) {
              _selectedYearIndex = 0;
            }

            final selectedYear = years[_selectedYearIndex];

            final seasons = selectedYear.seasons ?? [];

            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    /// years
                    SizedBox(
                      height: 42,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: ListView.separated(
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: years.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final year = years[index];

                            final isSelected = index == _selectedYearIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedYearIndex = index;

                                  /// reset season filter
                                  _selectedSeasonIndex = null;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : AppColors.chipBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.primaryLightTrack,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    year.year?.name ?? '',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
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
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// seasons
                    if (seasons.isNotEmpty) ...[
                      SizedBox(
                        height: 38,
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: ListView.separated(
                            reverse: true,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: seasons.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final season = seasons[index];

                              final isSelected = _selectedSeasonIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedSeasonIndex == index) {
                                      _selectedSeasonIndex = null;
                                    } else {
                                      _selectedSeasonIndex = index;
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.secondary
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.secondary
                                          : AppColors.primaryLightTrack,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      season.season?.name ?? '',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    /// content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(seasons.length, (seasonIndex) {
                          final season = seasons[seasonIndex];

                          final isSeasonSelected =
                              _selectedSeasonIndex == seasonIndex;

                          /// if season selected -> hide others
                          if (_selectedSeasonIndex != null &&
                              !isSeasonSelected) {
                            return const SizedBox.shrink();
                          }

                          final subjects = season.subjects ?? [];

                          if (subjects.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppColors.primaryLightTrack,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSeasonSelected
                                          ? AppColors.secondary
                                          : AppColors.chipBackground,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      season.season?.name ?? '',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSeasonSelected
                                            ? Colors.white
                                            : AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              ...subjects.map((subject) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: SubjectCard(
                                    title: subject.name ?? '',
                                    imageUrl: subject.imageUrl ?? '',
                                    year: selectedYear.year?.name ?? '',
                                    semester: season.season?.name ?? '',
                                    onTap: () {
                                      context.push(
                                        "${GRouter.config.applicationRoutes.coursesBySubject}/${subject.id}/true",
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
