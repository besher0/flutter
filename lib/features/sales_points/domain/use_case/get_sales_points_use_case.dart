import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/sale_point_model.dart';
import '../repository/sales_points_repository.dart';

@injectable
class GetSalesPointsUseCase extends UseCase<List<SalePoint>, NoParams> {
  final SalesPointsRepository repository;

  GetSalesPointsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SalePoint>>> call(NoParams param) {
    return repository.getSalesPoints();
  }
}
