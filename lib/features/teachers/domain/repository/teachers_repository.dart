import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_affilations_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_details_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_revenue_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_withdrawal_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/teacher_model.dart';
import '../use_case/add_or_remove_affiliations_usecase.dart';

abstract class TeachersRepository {
  Future<Either<Failure, TeachersResponseModel>> getTeachers();

  Future<Either<Failure, List<TeacherAffiliationsResponseModel>>>
  getTeacherAffiliations();

  Future<Either<Failure, List<Teacher>>> getLikedTeachers();

  Future<Either<Failure, TeacherDetailsResponseModel>> getTeacherDetails(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, bool>> likeTeacher(Map<String, dynamic> data);
  Future<Either<Failure, bool>> addOrRemoveAffiliations(
    AddOrRemoveAffiliationsParams param,
  );

  Future<Either<Failure, bool>> unLikeTeacher(Map<String, dynamic> data);
  Future<Either<Failure, TeacherWithdrawalModel>> getTeacherWithdrawals(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, TeacherRevenueModel>> getRevenue();
}
