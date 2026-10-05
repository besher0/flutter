import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/teacher_model.dart';
import '../repository/teachers_repository.dart';

@injectable
class GetTeachersUseCase extends UseCase<TeachersResponseModel, NoParams> {
  final TeachersRepository repository;

  GetTeachersUseCase(this.repository);

  @override
  Future<Either<Failure, TeachersResponseModel>> call(NoParams param) {
    return repository.getTeachers();
  }
}
