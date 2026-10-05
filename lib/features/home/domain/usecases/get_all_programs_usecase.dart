import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetAllProgramsUsecase
    extends UseCase<List<Program>, GetAllProgramsParams> {
  final HomeRepository repository;

  GetAllProgramsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Program>>> call(GetAllProgramsParams param) {
    return repository.getAllPrograms(param.map);
  }
}

class GetAllProgramsParams {
  final int page;
  final int limit;

  GetAllProgramsParams({required this.page, required this.limit});

  Map<String, dynamic> get map => {
    "page": page.toString(),
    "limit": limit.toString(),
  };
}
