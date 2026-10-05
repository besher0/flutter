import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/teachers_repository.dart';

@injectable
class LikeTeacherUseCase extends UseCase<bool, ParamLikeTeacherUseCase> {
  final TeachersRepository repository;

  LikeTeacherUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ParamLikeTeacherUseCase param) {
    return repository.likeTeacher(param.data);
  }
}

class ParamLikeTeacherUseCase {
  final String teacherId;

  ParamLikeTeacherUseCase({required this.teacherId});

  Map<String, dynamic> get data => {"teacherId": teacherId};
}
