import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_details_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/teachers_repository.dart';

@injectable
class GetTeacherDetailsUsecase
    extends UseCase<TeacherDetailsResponseModel, TeacherDetailsParams> {
  final TeachersRepository repository;

  GetTeacherDetailsUsecase(this.repository);

  @override
  Future<Either<Failure, TeacherDetailsResponseModel>> call(
    TeacherDetailsParams param,
  ) {
    return repository.getTeacherDetails(param.map);
  }
}

class TeacherDetailsParams {
  final String teacherId;
  final int page;
  final int limit;

  TeacherDetailsParams({
    required this.teacherId,
    required this.page,
    required this.limit,
  });

  Map<String, dynamic> get map => {
    "id": teacherId,
    "page": page.toString(),
    "limit": limit.toString(),
  };
}
