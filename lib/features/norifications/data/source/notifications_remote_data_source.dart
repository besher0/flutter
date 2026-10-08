import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/detect_server.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/get.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/norifications/data/model/notification_model.dart';
import 'package:coursaty_student_and_teacher/features/norifications/domain/use_case/add_notification_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@injectable
class NotificationsRemoteDataSource {
  Future<List<Notification>> getNotifications() async {
    final prefs = GetIt.I<PrefsRepository>();
    if (prefs.isGuest || prefs.token == null) {
      throw StateError('Guest users cannot load notifications');
    }
    final GetClient<List<Notification>> getNotifications = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: prefs.isStudent
            ? EndPoints.getNotificationsEP
            : EndPoints.getTeacherNotifications,
        queryParameters: {"activeOnly": false.toString()},
        response: ResponseValue(
          fromJson: (data) => notificationsModelFromJson(data),
        ),
      ),
    );
    return getNotifications();
  }

  Future<Notification> addNotification(AddNotificationParams params) async {
    final PostClient<Notification> addNotification = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.addNotificationEP,
        data: params.map,
        response: ResponseValue(
          fromJson: (json) => Notification.fromJson(json),
        ),
      ),
    );
    return addNotification();
  }
}
