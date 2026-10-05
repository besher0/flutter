import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/teachers_repository.dart';

@injectable
class AddOrRemoveAffiliationsUsecase
    extends UseCase<bool, AddOrRemoveAffiliationsParams> {
  final TeachersRepository repository;

  AddOrRemoveAffiliationsUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddOrRemoveAffiliationsParams param) {
    return repository.addOrRemoveAffiliations(param);
  }
}

class AddOrRemoveAffiliationsParams {
  final String universityId;
  final String collegeId;
  final String? departmentId;
  final bool isForDelete;

  AddOrRemoveAffiliationsParams({
    required this.universityId,
    required this.collegeId,
    this.departmentId,
    required this.isForDelete,
  });

  Map<String, dynamic> get data => {
    "universityId": universityId,
    if (departmentId != null) "departmentId": departmentId,
    "collegeId": collegeId,
  };
}
