import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class UpdateStudentUsecase extends UseCase<bool, UpdateStudentParams> {
  final AuthRepository repository;

  UpdateStudentUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateStudentParams param) {
    return repository.updateStudent(param.data);
  }
}

class UpdateStudentParams {
  final String name;
  final String universityId;
  final String collegeId;
  final String? departmentId;
  final String collegeYearId;

  UpdateStudentParams({
    required this.name,
    required this.universityId,
    required this.collegeId,
    this.departmentId,
    required this.collegeYearId,
  });

  Map<String, dynamic> get data => {
    "name": name,
    "universityId": universityId,
    "collegeId": collegeId,
    if (departmentId != null) "departmentId": departmentId,
    "collegeYearId": collegeYearId,
  };
}
