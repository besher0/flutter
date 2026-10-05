import 'package:coursaty_student_and_teacher/features/home/data/models/teacher_summary_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetTeacherSummaryUsecase
    extends UseCase<TeacherSummaryResponseModel, NoParams> {
  final HomeRepository repository;

  GetTeacherSummaryUsecase(this.repository);

  @override
  Future<Either<Failure, TeacherSummaryResponseModel>> call(NoParams param) {
    return repository.getTeacherSummary();
  }
}
