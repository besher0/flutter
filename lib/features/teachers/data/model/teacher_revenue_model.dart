import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';

/// `GET teachers/me/revenue`: the teacher's revenues for the chosen period,
/// with the all-time withdrawal balance.
class TeacherRevenueModel {
  TeacherRevenueModel({
    required this.courses,
    required this.withdrawals,
    required this.invoice,
  });

  final List<TeacherCourseRevenue> courses;
  final TeacherBalance withdrawals;
  final RevenueInvoice invoice;

  factory TeacherRevenueModel.fromJson(Map<String, dynamic> json) =>
      TeacherRevenueModel(
        courses: json['courses'] is List
            ? (json['courses'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(TeacherCourseRevenue.fromJson)
                  .toList()
            : [],
        withdrawals: TeacherBalance.fromJson(
          json['withdrawals'] is Map<String, dynamic>
              ? json['withdrawals']
              : const {},
        ),
        invoice: RevenueInvoice.fromJson(
          json['invoice'] is Map<String, dynamic> ? json['invoice'] : const {},
        ),
      );
}

/// All-time balance: earnings minus approved withdrawals.
class TeacherBalance {
  TeacherBalance({
    required this.withdrawnAmount,
    required this.remainingAmount,
    required this.withdrawalCount,
  });

  final double withdrawnAmount;
  final double remainingAmount;
  final int withdrawalCount;

  factory TeacherBalance.fromJson(Map<String, dynamic> json) => TeacherBalance(
    withdrawnAmount: revenueDouble(json['withdrawnAmount']),
    remainingAmount: revenueDouble(json['remainingAmount']),
    withdrawalCount: revenueInt(
      json['withdrawalCount'] ?? json['withdrawalsCount'],
    ),
  );
}

class TeacherCourseRevenue {
  TeacherCourseRevenue({
    required this.id,
    required this.name,
    required this.publishedAt,
    required this.expiresAt,
    required this.price,
    required this.isCompleted,
    required this.ratingAverage,
    required this.ratersCount,
    required this.teacherPercentage,
  });

  final String? id;
  final String name;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final double price;
  final bool isCompleted;
  final double ratingAverage;
  final int ratersCount;
  final double teacherPercentage;

  factory TeacherCourseRevenue.fromJson(Map<String, dynamic> json) {
    final course = json['course'] is Map<String, dynamic>
        ? json['course'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rating = json['rating'] is Map<String, dynamic>
        ? json['rating'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final revenue = json['revenue'] is Map<String, dynamic>
        ? json['revenue'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return TeacherCourseRevenue(
      id: course['id'] as String?,
      name: course['name'] as String? ?? '-',
      publishedAt: DateTime.tryParse(course['publishedAt']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(course['expiresAt']?.toString() ?? ''),
      price: revenueDouble(course['price']),
      isCompleted: course['isCompleted'] == true,
      ratingAverage: revenueDouble(rating['average']),
      ratersCount: revenueInt(rating['ratersCount']),
      teacherPercentage: revenueDouble(revenue['teacherPercentage']),
    );
  }
}
