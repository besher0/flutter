import 'package:coursaty_student_and_teacher/features/courses/data/model/resulotion_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses resolution size from the backend size field', () {
    final resolution = ResolutionModel.fromJson({
      'resolution': '720p',
      'size': 52 * 1024 * 1024,
    });

    expect(resolution.resolution, '720p');
    expect(resolution.sizeBytes, 52 * 1024 * 1024);
  });
}
