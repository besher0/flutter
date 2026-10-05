import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TryAgainWidget extends StatelessWidget {
  const TryAgainWidget({super.key, required this.onPress});

  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 15,
        children: [
          25.verticalSpace,
          Text("حدث خطأ ما", style: GoogleFonts.cairo(fontSize: 20)),
          CoursatyPrimaryButton(label: "إعادة المحاولة", onPressed: onPress),
        ],
      ),
    );
  }
}
