import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:coursaty_student_and_teacher/services/network_time_protocol_service.dart';
import 'package:coursaty_student_and_teacher/services/notification_service/handle_notification/notification_process.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'core/di/di_container.dart';
import 'coursaty_app.dart';
import 'firebase_options.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter/services.dart';

bool isDateFraud = false;

///   student
///   0968045022
///   12345678
///   teacher
///   0939517639
///   ios
///   student
///   0968045822

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     HydratedBloc.storage = await HydratedStorage.build(
//       storageDirectory: HydratedStorageDirectory(
//         (await getApplicationDocumentsDirectory()).path,
//       ),
//     );
//   } catch (e) {
//     print(e);
//   }
//   await Future.wait([
//     EasyLocalization.ensureInitialized(),
//     configureDependencies(),
//     NotificationProcess.init(),
//     DeviceInfoService.init(),
//   ]);
//   isDateFraud = NetworkTimeProtocolService.checkLocalTimeValidity();
//   runApp(const CoursatyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('STEP 1: START');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  print('STEP 2: Orientation OK');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('STEP 3: Firebase OK');

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await getApplicationDocumentsDirectory()).path,
      ),
    );
    print('STEP 4: HydratedBloc OK');
  } catch (e, stackTrace) {
    print('INIT ERROR: $e');
    print(stackTrace);
  }

  print('STEP 5: EasyLocalization START');
  await EasyLocalization.ensureInitialized();
  print('STEP 5: EasyLocalization OK');

  print('STEP 6: DI START');
  await configureDependencies();
  print('STEP 6: DI OK');

  print('STEP 7: Notification START');
  await NotificationProcess.init();
  print('STEP 7: Notification OK');

  print('STEP 8: DeviceInfo START');
  await DeviceInfoService.init();
  print('STEP 8: DeviceInfo OK');

  print('STEP 9: Time check START');
  isDateFraud = NetworkTimeProtocolService.checkLocalTimeValidity();
  print('STEP 9: Time check OK - isDateFraud=$isDateFraud');

  print('STEP 10: RUN APP');
  runApp(const CoursatyApp());
}