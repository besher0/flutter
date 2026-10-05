import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../bloc/home_bloc.dart';
import '../widgets/subject_card.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(GetAllPrograms(reset: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TitleAppBar(
        title: 'البرامج',
        onBackTap: () {
          context.pop();
        },
      ),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.allPrograms.isLoading &&
                state.allPrograms.items.isEmpty) {
              return Center(child: CoursatyAppLoader());
            }
            final programs = state.allPrograms.items;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        (0.7 * scrollInfo.metrics.maxScrollExtent)) {
                      BlocProvider.of<HomeBloc>(context).add(GetAllPrograms());
                    }
                    return false;
                  },
                  child: Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<HomeBloc>(
                          context,
                        ).add(GetAllPrograms(reset: true));
                      },
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: programs.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        separatorBuilder: (context, index) {
                          return 15.verticalSpace;
                        },
                        itemBuilder: (context, index) {
                          final program = programs[index];
                          return SubjectCard(
                            title: program.name ?? '',
                            imageUrl: program.image ?? '',
                            // teacher: program.teacherName,
                            onTap: () {
                              context.push(
                                "${GRouter.config.applicationRoutes.coursesBySubject}/${program.id}/false",
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                10.verticalSpace,
                if (state.allPrograms.items.isNotEmpty &&
                    state.allPrograms.isLoading) ...{
                  Center(child: CoursatyAppLoader()),
                },
                15.verticalSpace,
              ],
            );
          },
        ),
      ),
    );
  }
}
