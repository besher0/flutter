import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/teachers_repository.dart';

@injectable
class UnlikeTeacherUsecase extends UseCase<bool, ParamUnLikeTeacherUseCase> {
  final TeachersRepository repository;

  UnlikeTeacherUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ParamUnLikeTeacherUseCase param) {
    return repository.unLikeTeacher(param.data);
  }
}

class ParamUnLikeTeacherUseCase {
  final String teacherId;

  ParamUnLikeTeacherUseCase({required this.teacherId});

  Map<String, dynamic> get data => {"teacherId": teacherId};
}
