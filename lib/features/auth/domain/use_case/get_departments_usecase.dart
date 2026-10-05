import 'package:coursaty_student_and_teacher/features/auth/data/model/departments_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class GetDepartmentsUsecase
    extends UseCase<List<DepartmentsResponseModel>, String> {
  final AuthRepository repository;

  GetDepartmentsUsecase(this.repository);

  @override
  Future<Either<Failure, List<DepartmentsResponseModel>>> call(
    String collegeId,
  ) {
    return repository.getDepartments(collegeId);
  }
}
