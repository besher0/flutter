import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/search_response_model.dart';
import '../repositories/home_repository.dart';

@injectable
class SearchUsecase extends UseCase<SearchResponseModel, SearchParams> {
  final HomeRepository repository;

  SearchUsecase(this.repository);

  @override
  Future<Either<Failure, SearchResponseModel>> call(SearchParams params) {
    return repository.search(params);
  }
}

class SearchParams {
  final int page;
  final int limit;
  final String query;

  SearchParams({required this.page, required this.limit, required this.query});

  Map<String, dynamic> get map => {
    "page": page.toString(),
    "limit": limit.toString(),
    "q": query,
    "deviceId": DeviceInfoService.getDeviceId(),
  };
}
