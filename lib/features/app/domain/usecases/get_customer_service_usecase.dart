import 'package:coursaty_student_and_teacher/features/app/data/models/customer_service_model.dart';
import 'package:coursaty_student_and_teacher/features/app/domain/repository/app_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetCustomerServiceUsecase
    extends UseCase<CustomerServiceModel, NoParams> {
  final AppRepository repository;

  GetCustomerServiceUsecase(this.repository);

  @override
  Future<Either<Failure, CustomerServiceModel>> call(NoParams param) {
    return repository.getCustomerService();
  }
}
