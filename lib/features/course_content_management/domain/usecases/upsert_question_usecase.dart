import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpsertQuestionUsecase extends UseCase<bool, UpsertQuestionParams> {
  final CourseContentManagementRepository repository;

  UpsertQuestionUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpsertQuestionParams param) {
    return repository.upsertQuestion(param);
  }
}

class UpsertQuestionParams {
  final String lectureId;
  final String? questionText;
  String? imageUrl;
  final String? explanation;
  final List<Option> options;
  final String? questionId;
  final int? sortOrder;

  UpsertQuestionParams({
    required this.lectureId,
    this.questionText,
    this.questionId,
    this.imageUrl,
    this.explanation,
    required this.options,
    this.sortOrder,
  });

  Map<String, dynamic> get data => {
    "lectureId": lectureId,
    if (questionText != null) "questionText": questionText,
    if (sortOrder != null) "sortOrder": sortOrder,
    if (imageUrl != null) "imageUrl": imageUrl,
    "explanation": explanation,
    "questionType": "multiple_choice",
    "points": 1,
    "options": options.map((x) => x.toJson()).toList(),
  };
}

class Option {
  final String optionText;
  final bool isCorrect;
  final int sortOrder;

  Option({
    required this.optionText,
    required this.isCorrect,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
    "optionText": optionText,
    "isCorrect": isCorrect,
    "sortOrder": sortOrder,
  };
}
