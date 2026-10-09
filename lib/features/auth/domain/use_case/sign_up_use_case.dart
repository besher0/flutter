import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../../../services/device_info_service.dart';
import '../../../../services/notification_service/handle_notification/notification_process.dart';
import '../../data/model/auth_model.dart';
import '../repository/auth_repository.dart';

@injectable
class SignUpUseCase extends UseCase<AuthModel, ParamSignUp> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, AuthModel>> call(ParamSignUp param) {
    return repository.signUp(param.data);
  }
}

class ParamSignUp {
  final String name;
  final String gender;
  final String phone;
  final String password;
  final String userableType;

  final CreateTeacherParams? teacherParams;
  final CreateStudentParams? studentParams;

  ParamSignUp({
    required this.phone,
    required this.userableType,
    required this.password,
    required this.name,
    required this.gender,
    this.teacherParams,
    this.studentParams,
  });

  Map<String, dynamic> get data => {
    "phone": phone,
    "password": password,
    "userableType": userableType,
    "gender": gender,
    "fcmToken": NotificationProcess.myFcmToken,
    // A student account is bound to the device it is created on.
    if (userableType == 'STUDENT')
      "loginDeviceId": DeviceInfoService.getLoginDeviceId(),
    if (teacherParams != null) "teacher": teacherParams!.data,
    if (studentParams != null) "student": studentParams!.data,
  };
}

class CreateTeacherParams {
  final String name;
  final String description;
  final String? image;
  final String? instagramUrl;
  final String universityId;
  final String collegeId;
  final String? departmentId;

  CreateTeacherParams({
    required this.name,
    required this.description,
    this.image,
    this.instagramUrl,
    required this.universityId,
    required this.collegeId,
    this.departmentId,
  });

  Map<String, dynamic> get data => {
    "name": name,
    "description": description,
    "instagramUrl": instagramUrl,
    "universityId": universityId,
    "collegeId": collegeId,
    if (departmentId != null) "departmentId": departmentId,
    "affiliations": [
      {
        "universityId": universityId,
        "collegeId": collegeId,
        if (departmentId != null) "departmentId": departmentId,
      },
    ],
  };
}

class CreateStudentParams {
  final String name;
  final String universityNumber;
  final String universityId;
  final String collegeId;
  final String? departmentId;
  final String collegeYearId;

  CreateStudentParams({
    required this.name,
    required this.universityNumber,
    required this.universityId,
    required this.collegeId,
    this.departmentId,
    required this.collegeYearId,
  });

  Map<String, dynamic> get data => {
    "name": name,
    "universityNumber": universityNumber,
    "universityId": universityId,
    "collegeId": collegeId,
    if (departmentId != null) "departmentId": departmentId,
    "collegeYearId": collegeYearId,
  };
}
