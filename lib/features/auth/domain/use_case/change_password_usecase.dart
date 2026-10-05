import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class ChangePasswordUsecase extends UseCase<bool, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePasswordUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ChangePasswordParams param) {
    return repository.changePassword(param);
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> get data => {
    "currentPassword": currentPassword,
    "newPassword": newPassword,
    "confirmNewPassword": newPassword,
  };
}
