import 'package:coursaty_student_and_teacher/core/models/revenue_invoice_model.dart';

/// `GET courses/:id/statistics`: one course's revenues for the chosen period.
///
/// Amounts and percentages are read as numbers of any kind (the backend
/// rounds them to two decimals).
class CourseStatisticsModel {
  CourseStatisticsModel({
    required this.publishedAt,
    required this.expiresAt,
    required this.priceBeforeDiscount,
    required this.priceAfterDiscount,
    required this.discountPercentage,
    required this.isPriceVisible,
    required this.ratingAverage,
    required this.ratersCount,
    required this.myPercentage,
    required this.invoice,
  });

  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final double priceBeforeDiscount;
  final double priceAfterDiscount;
  final double discountPercentage;
  final bool isPriceVisible;
  final double ratingAverage;
  final int ratersCount;

  /// The caller's current share of each sale (teacher or platform).
  final double myPercentage;
  final RevenueInvoice invoice;

  /// This course's figures (the invoice holds only this course).
  RevenueSummary get summary => invoice.summary;

  RevenueCourseInvoice? get courseInvoice =>
      invoice.courses.isEmpty ? null : invoice.courses.first;

  factory CourseStatisticsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map(String key) => json[key] is Map<String, dynamic>
        ? json[key] as Map<String, dynamic>
        : const {};
    final course = map('course');
    final price = map('subscriptionPrice');
    final rating = map('rating');
    final percentages = map('percentages');
    return CourseStatisticsModel(
      publishedAt: DateTime.tryParse(course['publishedAt']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(course['expiresAt']?.toString() ?? ''),
      priceBeforeDiscount: revenueDouble(price['beforeDiscount']),
      priceAfterDiscount: revenueDouble(price['afterDiscount']),
      discountPercentage: revenueDouble(price['discountPercentage']),
      isPriceVisible: price['isPriceVisible'] is bool
          ? price['isPriceVisible'] as bool
          : true,
      ratingAverage: revenueDouble(rating['average']),
      ratersCount: revenueInt(rating['ratersCount']),
      myPercentage: revenueDouble(
        percentages['myPercentage'] ?? percentages['teacherPercentage'],
      ),
      invoice: RevenueInvoice.fromJson(map('invoice')),
    );
  }
}
