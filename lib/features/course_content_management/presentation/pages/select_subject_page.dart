import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/allowed_subjects_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/subject_card.dart';
import 'add_course_page.dart';

class SelectSubjectPage extends StatefulWidget {
  const SelectSubjectPage({super.key});

  @override
  State<SelectSubjectPage> createState() => _SelectSubjectPageState();
}

class _SelectSubjectPageState extends State<SelectSubjectPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CourseContentManagementBloc>(
      context,
    ).add(GetAllowedSubjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: "إضافة كورس",
        onBackTap: () {
          Navigator.pop(context);
        },
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
                Tab(text: 'مادة'),
                Tab(text: 'برنامج'),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<
              CourseContentManagementBloc,
              CourseContentManagementState
            >(
              builder: (context, state) {
                if (state.getAllowedSubjects.isLoading) {
                  return Center(child: CoursatyAppLoader());
                }
                List<Subject> allSubjects =
                    state.getAllowedSubjectsResponseModel?.subjects ?? [];
                final programs = allSubjects
                    .where((item) => item.isProgram == true)
                    .toList();
                final subjects = allSubjects
                    .where((item) => item.isProgram == false)
                    .toList();
                return Expanded(
                  child: TabBarView(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: subjects.length,
                        shrinkWrap: true,
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: AppColors.primaryLightTrack,
                          ),
                        ),
                        itemBuilder: (context, i) {
                          return SubjectCard(
                            title: subjects[i].subjectName ?? '',
                            imageUrl: subjects[i].imageUrl ?? '',
                            year: subjects[i].academicYear?.name ?? '',
                            semester: subjects[i].season?.name ?? '',
                            onTap: () {
                              context.pushPage(
                                AddCoursePage(subjectId: subjects[i].id!),
                              );
                            },
                          );
                        },
                      ),
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: programs.length,
                        shrinkWrap: true,
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: AppColors.primaryLightTrack,
                          ),
                        ),
                        itemBuilder: (context, i) {
                          return SubjectCard(
                            title: programs[i].subjectName ?? '',
                            imageUrl: programs[i].imageUrl ?? '',
                            onTap: () {
                              context.pushPage(
                                AddCoursePage(subjectId: programs[i].id!),
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
    );
  }
}
