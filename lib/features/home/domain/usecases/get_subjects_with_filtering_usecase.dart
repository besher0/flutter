import 'package:coursaty_student_and_teacher/features/home/data/models/filtered_subjects_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetSubjectsWithFilteringUsecase
    extends UseCase<StudentSubjectsModel, String> {
  final HomeRepository repository;

  GetSubjectsWithFilteringUsecase(this.repository);

  @override
  Future<Either<Failure, StudentSubjectsModel>> call(String collegeYearId) {
    return repository.getSubjectsWithFiltering(collegeYearId);
  }
}
