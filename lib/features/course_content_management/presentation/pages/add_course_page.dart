import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/teacher/course_details_section.dart';
import 'package:flutter/material.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key, required this.subjectId});

  final String subjectId;

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "إضافة كورس"),
      body: CourseDetailsSection(subjectId: widget.subjectId),
    );
  }
}
