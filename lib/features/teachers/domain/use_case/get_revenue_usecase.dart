import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_revenue_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/teachers_repository.dart';

@injectable
class GetRevenueUsecase extends UseCase<TeacherRevenueModel, RevenuePeriod> {
  final TeachersRepository repository;

  GetRevenueUsecase(this.repository);

  @override
  Future<Either<Failure, TeacherRevenueModel>> call(RevenuePeriod param) {
    return repository.getRevenue(param);
  }
}
