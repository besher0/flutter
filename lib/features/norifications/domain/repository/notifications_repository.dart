import 'package:coursaty_student_and_teacher/features/norifications/domain/use_case/add_notification_usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/notification_model.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<Notification>>> getNotifications();
  Future<Either<Failure, Notification>> addNotification(
    AddNotificationParams params,
  );
}
