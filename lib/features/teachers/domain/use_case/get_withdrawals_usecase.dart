import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_details_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_withdrawal_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/teachers_repository.dart';

@injectable
class GetWithdrawalsUsecase
    extends UseCase<TeacherWithdrawalModel, GetWithdrawalsParams> {
  final TeachersRepository repository;

  GetWithdrawalsUsecase(this.repository);

  @override
  Future<Either<Failure, TeacherWithdrawalModel>> call(
    GetWithdrawalsParams param,
  ) {
    return repository.getTeacherWithdrawals(param.map);
  }
}

class GetWithdrawalsParams {
  final int page;
  final int limit;

  GetWithdrawalsParams({required this.page, required this.limit});

  Map<String, dynamic> get map => {
    "page": page.toString(),
    "limit": limit.toString(),
  };
}
