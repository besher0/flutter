import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/features/norifications/domain/use_case/add_notification_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repository/notifications_repository.dart';
import '../model/notification_model.dart';
import '../source/notifications_remote_data_source.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImp extends NotificationsRepository
    with HandlingExceptionRequest {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImp(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Notification>>> getNotifications() =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.getNotifications(),
      );

  @override
  Future<Either<Failure, Notification>> addNotification(
    AddNotificationParams params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.addNotification(params),
    );
  }
}
