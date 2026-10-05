import 'package:coursaty_student_and_teacher/services/notification_service/handle_notification/notification_process.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class DeleteAccountUsecase extends UseCase<bool, NoParams> {
  final AuthRepository repository;

  DeleteAccountUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams param) {
    return repository.deleteAccount();
  }
}
