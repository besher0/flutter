import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/sale_point_model.dart';

abstract class SalesPointsRepository {
  Future<Either<Failure, List<SalePoint>>> getSalesPoints();
}
