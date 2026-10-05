import 'package:coursaty_student_and_teacher/features/auth/data/model/colleges_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class GetCollegesUsecase extends UseCase<List<CollegesResponseModel>, String?> {
  final AuthRepository repository;

  GetCollegesUsecase(this.repository);

  @override
  Future<Either<Failure, List<CollegesResponseModel>>> call(
    String? universityId,
  ) {
    return repository.getColleges(universityId);
  }
}
