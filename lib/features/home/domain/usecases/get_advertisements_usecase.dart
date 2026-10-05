import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/home_response_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetAdvertisementsUsecase extends UseCase<List<Advertisement>, NoParams> {
  final HomeRepository repository;

  GetAdvertisementsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Advertisement>>> call(NoParams param) {
    return repository.getAdvertisements();
  }
}
