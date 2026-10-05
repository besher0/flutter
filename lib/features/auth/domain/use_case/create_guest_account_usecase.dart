import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/guest_account_model.dart';
import '../repository/auth_repository.dart';

@injectable
class CreateGuestAccountUsecase
    extends UseCase<GuestAccountModel, CreateGuestAccountParams> {
  final AuthRepository repository;

  CreateGuestAccountUsecase(this.repository);

  @override
  Future<Either<Failure, GuestAccountModel>> call(
    CreateGuestAccountParams param,
  ) {
    return repository.createGuestAccount(param.data);
  }
}

class CreateGuestAccountParams {
  final String universityId;
  final String collegeId;
  final String departmentId;
  final String yearCollegeId;

  CreateGuestAccountParams({
    required this.universityId,
    required this.collegeId,
    required this.departmentId,
    required this.yearCollegeId,
  });

  Map<String, dynamic> get data => {
    "deviceId": DeviceInfoService.getDeviceId(),
    "universityId": universityId,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "collegeYearId": yearCollegeId,
  };
}
