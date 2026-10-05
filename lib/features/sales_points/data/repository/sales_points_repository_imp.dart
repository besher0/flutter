import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repository/sales_points_repository.dart';
import '../model/sale_point_model.dart';
import '../source/sales_points_remote_data_source.dart';

@LazySingleton(as: SalesPointsRepository)
class SalesPointsRepositoryImp extends SalesPointsRepository
    with HandlingExceptionRequest {
  final SalesPointsRemoteDataSource remoteDataSource;

  SalesPointsRepositoryImp(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SalePoint>>> getSalesPoints() =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.getSalesPoints(),
      );
}
