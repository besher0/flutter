import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/notification_model.dart';
import '../repository/notifications_repository.dart';

@injectable
class GetNotificationsUseCase extends UseCase<List<Notification>, NoParams> {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Notification>>> call(NoParams param) {
    return repository.getNotifications();
  }
}
