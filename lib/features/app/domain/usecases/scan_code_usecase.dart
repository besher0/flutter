import 'package:coursaty_student_and_teacher/features/app/domain/repository/app_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ScanCodeUsecase extends UseCase<String, String> {
  final AppRepository repository;

  ScanCodeUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(String code) {
    return repository.scanCode(code);
  }
}
