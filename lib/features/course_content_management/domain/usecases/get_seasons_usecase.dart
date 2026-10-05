import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/seasons_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetSeasonsUsecase extends UseCase<List<SeasonsModel>, NoParams> {
  final CourseContentManagementRepository repository;

  GetSeasonsUsecase(this.repository);

  @override
  Future<Either<Failure, List<SeasonsModel>>> call(NoParams params) {
    return repository.getAllSeasons();
  }
}
