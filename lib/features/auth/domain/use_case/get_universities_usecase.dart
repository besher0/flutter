import 'package:coursaty_student_and_teacher/features/auth/data/model/universities_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class GetUniversitiesUsecase
    extends UseCase<List<UniversitiesResponseModel>, NoParams> {
  final AuthRepository repository;

  GetUniversitiesUsecase(this.repository);

  @override
  Future<Either<Failure, List<UniversitiesResponseModel>>> call(
    NoParams param,
  ) {
    return repository.getUniversities();
  }
}
