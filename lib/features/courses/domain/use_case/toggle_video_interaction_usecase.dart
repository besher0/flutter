import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class ToggleVideoInteractionUsecase
    extends UseCase<bool, ToggleVideoInteractionParams> {
  final CoursesRepository repository;

  ToggleVideoInteractionUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleVideoInteractionParams param) {
    return repository.toggleVideoInteraction(param);
  }
}

class ToggleVideoInteractionParams {
  final String videoId;
  final String isLiked;

  ToggleVideoInteractionParams({required this.videoId, required this.isLiked});

  Map<String, dynamic> get data => {
    // "isLiked": isLiked,
    "videoId": videoId,
  };
}
