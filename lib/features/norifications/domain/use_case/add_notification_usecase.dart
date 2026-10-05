import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/notification_model.dart';
import '../repository/notifications_repository.dart';

@injectable
class AddNotificationUsecase
    extends UseCase<Notification, AddNotificationParams> {
  final NotificationsRepository repository;

  AddNotificationUsecase(this.repository);

  @override
  Future<Either<Failure, Notification>> call(AddNotificationParams params) {
    return repository.addNotification(params);
  }
}

class AddNotificationParams {
  final String title;
  final String description;
  final String collegeId;
  final String? link;
  final String? departmentId;

  AddNotificationParams({
    required this.title,
    required this.description,
    required this.collegeId,
    this.link,
    this.departmentId,
  });

  Map<String, dynamic> get map => {
    "title": title,
    "description": description,
    "link": link,
    "collegeId": collegeId,
    if (departmentId != null) ...{"departmentId": departmentId},
  };
}
