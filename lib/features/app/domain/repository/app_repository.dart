import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/customer_service_model.dart';

abstract class AppRepository {
  Future<Either<Failure, CustomerServiceModel>> getCustomerService();
  Future<Either<Failure, String>> scanCode(String code);
}
