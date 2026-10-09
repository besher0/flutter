enum InterestSource {
  qrScreenshot('QR_SCREENSHOT'),
  manual('MANUAL');

  const InterestSource(this.apiValue);
  final String apiValue;
}

class CoursePaymentInfo {
  const CoursePaymentInfo({
    required this.id,
    required this.name,
    this.imageUrl,
    this.basePrice,
    this.discountedPrice,
    this.paymentQrUrl,
    this.isFree,
    this.isExpired,
    this.expiresAt,
    this.isPriceVisible = true,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final num? basePrice;
  final num? discountedPrice;
  final String? paymentQrUrl;
  final bool? isFree;
  final bool? isExpired;
  final DateTime? expiresAt;

  /// Display only: the amount is still required for the payment flow.
  final bool isPriceVisible;

  num get finalPrice => discountedPrice ?? basePrice ?? 0;
  bool get hasPaymentQr => paymentQrUrl?.trim().isNotEmpty == true;
  bool get isExpiredNow =>
      isExpired == true ||
      (expiresAt != null && !expiresAt!.isAfter(DateTime.now()));
  bool get canStartReceiptFlow =>
      !isExpiredNow && isFree != true && finalPrice > 0 && hasPaymentQr;
  String get ineligibilityReason {
    if (isExpiredNow) return 'انتهت صلاحية هذا الكورس.';
    if (isFree == true) return 'هذا الكورس مجاني ولا يحتاج إلى إيصال دفع.';
    if (finalPrice <= 0) return 'لا يمكن الاشتراك لأن سعر الكورس غير صالح.';
    if (!hasPaymentQr) return 'رمز الدفع غير متاح لهذا الكورس حالياً.';
    return 'الكورس غير متاح للاشتراك حالياً.';
  }

  factory CoursePaymentInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['course'] is Map<String, dynamic>
        ? json['course'] as Map<String, dynamic>
        : json;
    final details = json['details'] is Map<String, dynamic>
        ? json['details'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final expiresAt = _parseDate(raw['expiresAt'] ?? details['expiresAt']);
    final isExpired = details['isExpired'] is bool
        ? details['isExpired'] as bool
        : (expiresAt != null && !expiresAt.isAfter(DateTime.now()));
    return CoursePaymentInfo(
      id: raw['id']?.toString() ?? '',
      name: raw['name']?.toString() ?? '',
      imageUrl: raw['imageUrl']?.toString(),
      basePrice: _parseNum(raw['basePrice'] ?? raw['price']),
      discountedPrice: _parseNum(raw['discountedPrice']),
      paymentQrUrl: raw['paymentQrUrl']?.toString(),
      isFree: raw['isFree'] is bool ? raw['isFree'] as bool : null,
      isExpired: isExpired,
      expiresAt: expiresAt,
      isPriceVisible: raw['isPriceVisible'] is bool
          ? raw['isPriceVisible'] as bool
          : true,
    );
  }

  static num? _parseNum(dynamic value) =>
      value is num ? value : num.tryParse('$value');
  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class SubscriptionRequestSummary {
  const SubscriptionRequestSummary({
    required this.id,
    required this.status,
    this.receiptUrl,
    this.adminNote,
    this.createdAt,
  });

  final String id;
  final String status;
  final String? receiptUrl;
  final String? adminNote;
  final DateTime? createdAt;

  bool get isPending => status.toUpperCase() == 'PENDING';

  factory SubscriptionRequestSummary.fromJson(Map<String, dynamic> json) =>
      SubscriptionRequestSummary(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING',
        receiptUrl: json['receiptUrl']?.toString(),
        adminNote: json['adminNote']?.toString(),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString()),
      );
}

class CourseInterest {
  const CourseInterest({
    required this.id,
    required this.courseId,
    required this.course,
    required this.source,
    this.createdAt,
    this.pendingRequest,
  });

  final String id;
  final String courseId;
  final CoursePaymentInfo course;
  final InterestSource source;
  final DateTime? createdAt;
  final SubscriptionRequestSummary? pendingRequest;

  bool get isAwaitingReceipt => pendingRequest == null;

  CourseInterest copyWith({SubscriptionRequestSummary? pendingRequest}) =>
      CourseInterest(
        id: id,
        courseId: courseId,
        course: course,
        source: source,
        createdAt: createdAt,
        pendingRequest: pendingRequest ?? this.pendingRequest,
      );

  factory CourseInterest.fromJson(Map<String, dynamic> json) {
    final rawCourse = json['course'] is Map<String, dynamic>
        ? json['course'] as Map<String, dynamic>
        : <String, dynamic>{'id': json['courseId']};
    final source = json['source']?.toString().toUpperCase();
    final request = json['pendingRequest'] ?? json['subscriptionRequest'];
    return CourseInterest(
      id: json['id']?.toString() ?? '',
      courseId:
          json['courseId']?.toString() ?? rawCourse['id']?.toString() ?? '',
      course: CoursePaymentInfo.fromJson(rawCourse),
      source: source == InterestSource.qrScreenshot.apiValue
          ? InterestSource.qrScreenshot
          : InterestSource.manual,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
      pendingRequest: request is Map<String, dynamic>
          ? SubscriptionRequestSummary.fromJson(request)
          : null,
    );
  }
}
