import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/guest_account_model.dart';
import '../repository/auth_repository.dart';

@injectable
class GetGuestAccountUsecase extends UseCase<GuestAccountModel, NoParams> {
  final AuthRepository repository;

  GetGuestAccountUsecase(this.repository);

  @override
  Future<Either<Failure, GuestAccountModel>> call(NoParams params) {
    return repository.getGuestAccount(DeviceInfoService.getDeviceId());
  }
}
