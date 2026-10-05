import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class GetAcademicYearsUsecase
    extends UseCase<List<AcademicYearsResponseModel>, String> {
  final AuthRepository repository;

  GetAcademicYearsUsecase(this.repository);

  @override
  Future<Either<Failure, List<AcademicYearsResponseModel>>> call(
    String collegeId,
  ) {
    return repository.getAcademicYears(collegeId);
  }
}
