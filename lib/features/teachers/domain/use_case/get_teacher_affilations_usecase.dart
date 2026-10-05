import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/teacher_affilations_model.dart';
import '../repository/teachers_repository.dart';

@injectable
class GetTeacherAffiliationsUsecase
    extends UseCase<List<TeacherAffiliationsResponseModel>, NoParams> {
  final TeachersRepository repository;

  GetTeacherAffiliationsUsecase(this.repository);

  @override
  Future<Either<Failure, List<TeacherAffiliationsResponseModel>>> call(
    NoParams param,
  ) {
    return repository.getTeacherAffiliations();
  }
}
