import 'package:coursaty_student_and_teacher/app/widgets/zoomable_image.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/rating_widget.dart';
import 'package:flutter/cupertino.dart';

class ImageHeader extends StatelessWidget {
  const ImageHeader({
    super.key,
    required this.image,
    this.courseId,
    this.isFreeCourse = false,
  });

  final String image;
  final String? courseId;
  final bool isFreeCourse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ZoomableImage(imageUrl: image, height: 180, width: double.infinity),
          if (courseId != null)
            Positioned(
              left: 10,
              top: 10,
              child: RatingWidget(
                courseId: courseId!,
                isFreeCourse: isFreeCourse,
              ),
            ),
        ],
      ),
    );
  }
}
