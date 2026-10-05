import 'package:coursaty_student_and_teacher/features/courses/data/model/video_interaction_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class GetVideoInteractionsUsecase
    extends UseCase<VideoInteractionModel, String> {
  final CoursesRepository repository;

  GetVideoInteractionsUsecase(this.repository);

  @override
  Future<Either<Failure, VideoInteractionModel>> call(String videoId) {
    return repository.getVideoInteractions(videoId);
  }
}
