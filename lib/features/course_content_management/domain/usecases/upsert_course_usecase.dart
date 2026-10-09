import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpsertCourseUsecase extends UseCase<bool, UpsertCourseParams> {
  final CourseContentManagementRepository repository;

  UpsertCourseUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpsertCourseParams params) {
    return repository.createCourse(params);
  }
}

class UpsertCourseParams {
  final String name;
  final String description;
  String? imageUrl;
  final String subjectId;
  final String categoryId;
  final int price;

  /// Final price after discount (equal to [price] when there is no discount).
  /// The backend's `courseDiscountPercentage` input is a legacy alias for this
  /// same final price, so a percentage must never be sent.
  final int discountedPrice;
  // final double duration;
  final bool isFree;

  /// Whether students see the price (base, discount and final).
  final bool isPriceVisible;
  final DateTime? expiresAt;
  final String? introVideoUrl;
  final String? discussionGroupUrl;
  final String? telegramUrl;
  final String? instagramUrl;
  final String? courseId;

  final String? seasonId; // universityId, collegeId, yearId;
  // final String? departmentId;

  UpsertCourseParams({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.subjectId,
    required this.categoryId,
    required this.price,
    required this.discountedPrice,
    // required this.duration,
    required this.isFree,
    this.isPriceVisible = true,
    this.expiresAt,
    this.introVideoUrl,
    this.discussionGroupUrl,
    this.telegramUrl,
    this.instagramUrl,
    this.courseId,
    this.seasonId,
    // required this.universityId,
    // required this.collegeId,
    // required this.yearId,
    // this.departmentId,
  });

  Map<String, dynamic> get map => {
    "name": name,
    "description": description,
    if (imageUrl != null) "imageUrl": imageUrl,
    "subjectId": subjectId,
    // "collegeYearId": yearId,
    if (seasonId != null) "seasonId": seasonId,
    // "universityId": universityId,
    // "collegeId": collegeId,
    // if (departmentId != null) "departmentId": departmentId,
    "categoryId": categoryId,
    "price": price,
    "discountedPrice": discountedPrice,
    // "duration": duration,
    "isFree": isFree,
    "isPriceVisible": isPriceVisible,
    if (expiresAt != null) "expiresAt": expiresAt!.toIso8601String(),
    if (introVideoUrl != null) "introVideoUrl": introVideoUrl,
    if (courseId != null || telegramUrl != null) "telegramUrl": telegramUrl,
    if (discussionGroupUrl != null) "discussionGroupUrl": discussionGroupUrl,
    if (instagramUrl != null) "instagramUrl": instagramUrl,
  };
}
