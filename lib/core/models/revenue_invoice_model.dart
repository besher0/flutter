/// The analytical revenue invoice the backend attaches to every revenue
/// report (teacher revenues, course statistics).
///
/// Every amount is read as a number of any kind: the backend rounds money and
/// percentages to two decimals, so an `int` field would fail on values such as
/// 66.67.
library;

double revenueDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int revenueInt(dynamic value) => revenueDouble(value).round();

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) =>
    value is List
    ? value.whereType<Map<String, dynamic>>().map(fromJson).toList()
    : <T>[];

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};

/// Period sent to the revenue endpoints as `year` / `month`.
class RevenuePeriod {
  const RevenuePeriod._(this.label, {this.year, this.month});

  static const allTime = RevenuePeriod._('كل الفترات');

  factory RevenuePeriod.thisMonth([DateTime? now]) {
    final date = now ?? DateTime.now();
    return RevenuePeriod._('هذا الشهر', year: date.year, month: date.month);
  }

  factory RevenuePeriod.lastMonth([DateTime? now]) {
    final date = now ?? DateTime.now();
    final previous = DateTime(date.year, date.month - 1);
    return RevenuePeriod._(
      'الشهر الماضي',
      year: previous.year,
      month: previous.month,
    );
  }

  factory RevenuePeriod.thisYear([DateTime? now]) =>
      RevenuePeriod._('هذه السنة', year: (now ?? DateTime.now()).year);

  static List<RevenuePeriod> options([DateTime? now]) => [
    allTime,
    RevenuePeriod.thisMonth(now),
    RevenuePeriod.lastMonth(now),
    RevenuePeriod.thisYear(now),
  ];

  final String label;
  final int? year;
  final int? month;

  /// Values are strings: requests are built with Dart's `Uri`, which only
  /// accepts `String` query values. Sending the `int` year made every period
  /// other than "all time" throw before the request left the device.
  Map<String, String> toQuery() => {
    if (year != null) 'year': '$year',
    if (month != null) 'month': '$month',
  };

  @override
  bool operator ==(Object other) =>
      other is RevenuePeriod && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

class RevenueInvoice {
  RevenueInvoice({
    required this.summary,
    required this.courses,
    required this.monthly,
  });

  final RevenueSummary summary;
  final List<RevenueCourseInvoice> courses;

  /// Oldest month first; months without sales are not listed.
  final List<RevenueMonth> monthly;

  factory RevenueInvoice.fromJson(Map<String, dynamic> json) => RevenueInvoice(
    summary: RevenueSummary.fromJson(_map(json['summary'])),
    courses: _list(json['courses'], RevenueCourseInvoice.fromJson),
    monthly: _list(json['monthly'], RevenueMonth.fromJson),
  );

  RevenueCourseInvoice? courseById(String? id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }
}

class RevenueSummary {
  RevenueSummary({
    required this.subscriptions,
    required this.uniqueStudents,
    required this.initialSubscriptions,
    required this.renewals,
    required this.grossRevenue,
    required this.courseDiscount,
    required this.codeDiscount,
    required this.totalDiscount,
    required this.totalRevenues,
    required this.teacherRevenue,
    required this.platformRevenue,
  });

  /// Activations and renewals.
  final int subscriptions;
  final int uniqueStudents;
  final int initialSubscriptions;
  final int renewals;

  /// List prices before any discount.
  final double grossRevenue;
  final double courseDiscount;
  final double codeDiscount;
  final double totalDiscount;

  /// What students actually paid.
  final double totalRevenues;
  final double teacherRevenue;
  final double platformRevenue;

  double get averagePerSubscription =>
      subscriptions == 0 ? 0 : totalRevenues / subscriptions;

  double get teacherShare =>
      totalRevenues == 0 ? 0 : teacherRevenue * 100 / totalRevenues;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    final courseDiscount = revenueDouble(json['courseDiscount']);
    final codeDiscount = revenueDouble(json['codeDiscount']);
    final totalDiscount = revenueDouble(json['totalDiscount']);
    final totalRevenues = revenueDouble(json['totalRevenues']);
    final subscriptions = revenueInt(json['totalSubscribers']);
    final gross = revenueDouble(json['grossRevenue']);
    final renewals = revenueInt(json['renewals']);
    return RevenueSummary(
      subscriptions: subscriptions,
      uniqueStudents: revenueInt(json['uniqueSubscribersCount']),
      initialSubscriptions: json.containsKey('initialSubscriptions')
          ? revenueInt(json['initialSubscriptions'])
          : subscriptions - renewals,
      renewals: renewals,
      // Older servers do not send the list total: rebuild it.
      grossRevenue: gross > 0 ? gross : totalRevenues + totalDiscount,
      courseDiscount: courseDiscount,
      codeDiscount: codeDiscount,
      totalDiscount: totalDiscount,
      totalRevenues: totalRevenues,
      teacherRevenue: revenueDouble(json['teacherRevenue']),
      platformRevenue: revenueDouble(json['platformRevenue']),
    );
  }
}

class RevenueCourseInvoice {
  RevenueCourseInvoice({
    required this.id,
    required this.name,
    required this.lineItems,
    required this.codeGroups,
    required this.summary,
  });

  final String? id;
  final String name;
  final List<RevenueLineItem> lineItems;
  final List<RevenueCodeGroup> codeGroups;
  final RevenueSummary summary;

  factory RevenueCourseInvoice.fromJson(Map<String, dynamic> json) {
    final course = _map(json['course']);
    return RevenueCourseInvoice(
      id: course['id'] as String?,
      name: course['name'] as String? ?? '-',
      lineItems: _list(json['lineItems'], RevenueLineItem.fromJson),
      codeGroups: _list(json['codeGroups'], RevenueCodeGroup.fromJson),
      summary: RevenueSummary.fromJson(_map(json['summary'])),
    );
  }
}

/// Subscriptions sold at one price (list price, discounts and share).
class RevenueLineItem {
  RevenueLineItem({
    required this.coursePrice,
    required this.subscriptions,
    required this.discountPercentage,
    required this.discountPerSubscription,
    required this.subtotal,
    required this.teacherPercentage,
    required this.teacherRevenue,
    required this.platformRevenue,
  });

  final double coursePrice;
  final int subscriptions;
  final double discountPercentage;
  final double discountPerSubscription;
  final double subtotal;
  final double teacherPercentage;
  final double teacherRevenue;
  final double platformRevenue;

  double get paidPerSubscription => coursePrice - discountPerSubscription;

  factory RevenueLineItem.fromJson(Map<String, dynamic> json) {
    final discount = _map(json['discount']);
    return RevenueLineItem(
      coursePrice: revenueDouble(json['coursePrice']),
      subscriptions: revenueInt(json['subscribersCount']),
      discountPercentage: revenueDouble(discount['percentage']),
      discountPerSubscription: revenueDouble(discount['amountPerSubscriber']),
      subtotal: revenueDouble(json['subtotal']),
      teacherPercentage: revenueDouble(json['teacherPercentage']),
      teacherRevenue: revenueDouble(json['teacherRevenue']),
      platformRevenue: revenueDouble(json['platformRevenue']),
    );
  }
}

/// Sales through one code batch; [codeGroupId] null means paid receipts.
class RevenueCodeGroup {
  RevenueCodeGroup({
    required this.codeGroupId,
    required this.batchName,
    required this.discountPercentage,
    required this.subscriptions,
    required this.discountAmount,
    required this.revenue,
  });

  final String? codeGroupId;
  final String? batchName;
  final double discountPercentage;
  final int subscriptions;
  final double discountAmount;
  final double revenue;

  String get displayName => codeGroupId == null
      ? 'بدون كود (إيصالات دفع)'
      : (batchName?.trim().isNotEmpty == true
            ? batchName!.trim()
            : 'دفعة أكواد');

  factory RevenueCodeGroup.fromJson(Map<String, dynamic> json) =>
      RevenueCodeGroup(
        codeGroupId: json['codeGroupId'] as String?,
        batchName: json['batchName'] as String?,
        discountPercentage: revenueDouble(json['discountPercentage']),
        subscriptions: revenueInt(json['subscriptionsCount']),
        discountAmount: revenueDouble(json['discountAmount']),
        revenue: revenueDouble(json['revenue']),
      );
}

class RevenueMonth {
  RevenueMonth({
    required this.year,
    required this.month,
    required this.subscriptions,
    required this.totalRevenues,
    required this.teacherRevenue,
    required this.platformRevenue,
  });

  final int year;
  final int month;
  final int subscriptions;
  final double totalRevenues;
  final double teacherRevenue;
  final double platformRevenue;

  factory RevenueMonth.fromJson(Map<String, dynamic> json) => RevenueMonth(
    year: revenueInt(json['year']),
    month: revenueInt(json['month']),
    subscriptions: revenueInt(json['subscriptions']),
    totalRevenues: revenueDouble(json['totalRevenues']),
    teacherRevenue: revenueDouble(json['teacherRevenue']),
    platformRevenue: revenueDouble(json['platformRevenue']),
  );
}
