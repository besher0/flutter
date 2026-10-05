import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/widgets/teachers_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/teachers_bloc.dart';
import '../widgets/teacher_card.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TeachersBloc>(context).add(GetLikedTeachersEvent());
    BlocProvider.of<TeachersBloc>(context).add(GetTeachersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: TitleAppBar(
          title: "الأساتذة",
          onBackTap: () => Navigator.of(context).pop(),
          onBellTap: () {
            context.push(GRouter.config.applicationRoutes.notifications);
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              BlocBuilder<TeachersBloc, TeachersState>(
                buildWhen: (p, c) =>
                    p.likedTeachers != c.likedTeachers ||
                    p.getTeachersStatus != c.getTeachersStatus,
                builder: (context, state) {
                  if (state.getTeachersStatus.isLoading) {
                    return Center(child: CoursatyAppLoader());
                  }
                  return Expanded(
                    child: TeachersGrid(
                      teachers: state.teachers?.teachers ?? [],
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
