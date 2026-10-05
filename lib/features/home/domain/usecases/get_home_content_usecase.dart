import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetHomeContentUsecase extends UseCase<HomeResponseModel, int> {
  final HomeRepository repository;

  GetHomeContentUsecase(this.repository);

  @override
  Future<Either<Failure, HomeResponseModel>> call(int limit) {
    return repository.getHomeContent(limit);
  }
}
