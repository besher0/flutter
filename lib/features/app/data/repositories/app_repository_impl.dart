import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/app/data/models/customer_service_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/app_repository.dart';
import '../sources/app_remote_datasource.dart';

@LazySingleton(as: AppRepository)
class AppRepositoryImpl extends AppRepository with HandlingExceptionRequest {
  final AppRemoteDatasource datasource;

  AppRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, CustomerServiceModel>> getCustomerService() {
    return handlingExceptionRequest(tryCall: datasource.getCustomerService);
  }

  @override
  Future<Either<Failure, String>> scanCode(String code) {
    return handlingExceptionRequest(tryCall: () => datasource.scanCode(code));
  }
}
