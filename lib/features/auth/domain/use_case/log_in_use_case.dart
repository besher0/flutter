import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/use_case/use_case.dart';
import '../../../../services/device_info_service.dart';
import '../../data/model/auth_model.dart';
import '../repository/auth_repository.dart';

@injectable
class LogInUseCase extends UseCase<AuthModel, ParamLogIn> {
  final AuthRepository repository;

  LogInUseCase(this.repository);

  @override
  Future<Either<Failure, AuthModel>> call(ParamLogIn param) {
    return repository.logIn(param.data);
  }
}

class ParamLogIn {
  final String phone;
  final String password;

  ParamLogIn({required this.phone, required this.password});

  /// Students can only sign in from the device their account is bound to.
  Map<String, dynamic> get data => {
    "phone": phone,
    "password": password,
    "loginDeviceId": DeviceInfoService.getLoginDeviceId(),
  };
}
