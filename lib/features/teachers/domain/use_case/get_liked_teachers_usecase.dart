import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/teacher_model.dart';
import '../repository/teachers_repository.dart';

@injectable
class GetLikedTeachersUsecase extends UseCase<List<Teacher>, NoParams> {
  final TeachersRepository repository;

  GetLikedTeachersUsecase(this.repository);

  @override
  Future<Either<Failure, List<Teacher>>> call(NoParams param) {
    return repository.getLikedTeachers();
  }
}
