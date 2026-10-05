import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_affilations_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_details_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_revenue_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_withdrawal_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repository/teachers_repository.dart';
import '../../domain/use_case/add_or_remove_affiliations_usecase.dart';
import '../source/teachers_remote_data_source.dart';

@LazySingleton(as: TeachersRepository)
class TeachersRepositoryImp extends TeachersRepository
    with HandlingExceptionRequest {
  final TeachersRemoteDataSource remoteDataSource;

  TeachersRepositoryImp(this.remoteDataSource);

  @override
  Future<Either<Failure, TeachersResponseModel>> getTeachers() =>
      handlingExceptionRequest(tryCall: () => remoteDataSource.getTeachers());

  @override
  Future<Either<Failure, bool>> likeTeacher(Map<String, dynamic> data) =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.likeTeacher(data),
      );

  @override
  Future<Either<Failure, TeacherDetailsResponseModel>> getTeacherDetails(
    Map<String, dynamic> data,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getTeacherDetails(data),
    );
  }

  @override
  Future<Either<Failure, List<Teacher>>> getLikedTeachers() {
    return handlingExceptionRequest(tryCall: remoteDataSource.getLikedTeachers);
  }

  @override
  Future<Either<Failure, bool>> unLikeTeacher(Map<String, dynamic> data) =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.unLikeTeacher(data),
      );

  @override
  Future<Either<Failure, bool>> addOrRemoveAffiliations(
    AddOrRemoveAffiliationsParams param,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.addOrRemoveAffiliations(param),
    );
  }

  @override
  Future<Either<Failure, List<TeacherAffiliationsResponseModel>>>
  getTeacherAffiliations() {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getTeacherAffiliations(),
    );
  }

  @override
  Future<Either<Failure, TeacherRevenueModel>> getRevenue() {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getRevenue(),
    );
  }

  @override
  Future<Either<Failure, TeacherWithdrawalModel>> getTeacherWithdrawals(
    Map<String, dynamic> data,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getTeacherWithdrawals(data),
    );
  }
}
