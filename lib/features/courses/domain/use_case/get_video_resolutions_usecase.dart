import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/resulotion_model.dart';
import '../repository/courses_repository.dart';

@injectable
class GetVideoResolutionsUsecase
    extends UseCase<List<ResolutionModel>, String> {
  final CoursesRepository repository;

  GetVideoResolutionsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ResolutionModel>>> call(String videoId) {
    return repository.getVideoResolutions(videoId);
  }
}
