import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/widgets/teacher_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/router.dart';

class TeachersGrid extends StatelessWidget {
  const TeachersGrid({super.key, required this.teachers, this.paddingValue});

  final List<Teacher> teachers;
  final double? paddingValue;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: paddingValue ?? 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: (173 / 225).r,
      ),
      itemCount: teachers.length,
      itemBuilder: (context, i) {
        final teacher = teachers[i];
        return TeacherCard(
          id: teacher.id ?? '',
          name: teacher.name ?? '',
          imageUrl: teacher.image ?? '',
          coursesCount: (teacher.coursesCount ?? 0).toString(),
          likesCount: (teacher.likesCount ?? 0).toString(),
          onTap: () {
            context.push(
              '${GRouter.config.applicationRoutes.teacherDetails}/${teacher.id}/${teacher.name}',
            );
          },
        );
      },
    );
  }
}
