import 'package:coursaty_student_and_teacher/services/notification_service/handle_notification/notification_process.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

@injectable
class EditProfileUsecase extends UseCase<bool, UpdateProfileParams> {
  final AuthRepository repository;

  EditProfileUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateProfileParams param) {
    return repository.editProfile(param);
  }
}

class UpdateProfileParams {
  final String? name;
  final String? gender;
  final String? phone;
  final String? instagramUrl;
  final String? universityNumber;
  final String? description;
  String? imageUrl;

  UpdateProfileParams({
    this.name,
    this.gender,
    this.phone,
    this.instagramUrl,
    this.universityNumber,
    this.imageUrl,
    this.description,
  });

  Map<String, dynamic> get data => {
    if (name != null) "name": name,
    if (gender != null) "gender": gender,
    if (phone != null) "phone": phone,
    if (instagramUrl != null) "instagramUrl": instagramUrl,
    if (universityNumber != null) "universityNumber": universityNumber,
    if (imageUrl != null) "image": imageUrl,
    if (description != null) "description": description,
    "fcmToken": NotificationProcess.myFcmToken,
  };
}
