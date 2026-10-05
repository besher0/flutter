// To parse this JSON data, do
//
//     final teacherRevenueModel = teacherRevenueModelFromJson(jsonString);

import 'dart:convert';

TeacherRevenueModel teacherRevenueModelFromJson(String str) =>
    TeacherRevenueModel.fromJson(json.decode(str));

String teacherRevenueModelToJson(TeacherRevenueModel data) =>
    json.encode(data.toJson());

class TeacherRevenueModel {
  final Totals? totals;
  final List<TeacherRevenueModelCourse>? courses;
  final Invoice? invoice;

  TeacherRevenueModel({this.totals, this.courses, this.invoice});

  TeacherRevenueModel copyWith({
    Totals? totals,
    List<TeacherRevenueModelCourse>? courses,
    Invoice? invoice,
  }) => TeacherRevenueModel(
    totals: totals ?? this.totals,
    courses: courses ?? this.courses,
    invoice: invoice ?? this.invoice,
  );

  factory TeacherRevenueModel.fromJson(
    Map<String, dynamic> json,
  ) => TeacherRevenueModel(
    totals: json["totals"] == null ? null : Totals.fromJson(json["totals"]),
    courses: json["courses"] == null
        ? []
        : List<TeacherRevenueModelCourse>.from(
            json["courses"]!.map((x) => TeacherRevenueModelCourse.fromJson(x)),
          ),
    invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
  );

  Map<String, dynamic> toJson() => {
    "totals": totals?.toJson(),
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
    "invoice": invoice?.toJson(),
  };
}

class TeacherRevenueModelCourse {
  final CourseCourse? course;
  final int? subscribersCount;
  final Rating? rating;
  final Revenue? revenue;

  TeacherRevenueModelCourse({
    this.course,
    this.subscribersCount,
    this.rating,
    this.revenue,
  });

  TeacherRevenueModelCourse copyWith({
    CourseCourse? course,
    int? subscribersCount,
    Rating? rating,
    Revenue? revenue,
  }) => TeacherRevenueModelCourse(
    course: course ?? this.course,
    subscribersCount: subscribersCount ?? this.subscribersCount,
    rating: rating ?? this.rating,
    revenue: revenue ?? this.revenue,
  );

  factory TeacherRevenueModelCourse.fromJson(Map<String, dynamic> json) =>
      TeacherRevenueModelCourse(
        course: json["course"] == null
            ? null
            : CourseCourse.fromJson(json["course"]),
        subscribersCount: json["subscribersCount"],
        rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
        revenue: json["revenue"] == null
            ? null
            : Revenue.fromJson(json["revenue"]),
      );

  Map<String, dynamic> toJson() => {
    "course": course?.toJson(),
    "subscribersCount": subscribersCount,
    "rating": rating?.toJson(),
    "revenue": revenue?.toJson(),
  };
}

class CourseCourse {
  final String? id;
  final String? name;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final int? price;
  final bool? isCompleted;

  CourseCourse({
    this.id,
    this.name,
    this.publishedAt,
    this.expiresAt,
    this.price,
    this.isCompleted,
  });

  CourseCourse copyWith({
    String? id,
    String? name,
    DateTime? publishedAt,
    DateTime? expiresAt,
    int? price,
    bool? isCompleted,
  }) => CourseCourse(
    id: id ?? this.id,
    name: name ?? this.name,
    publishedAt: publishedAt ?? this.publishedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    price: price ?? this.price,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  factory CourseCourse.fromJson(Map<String, dynamic> json) => CourseCourse(
    id: json["id"],
    name: json["name"],
    publishedAt: json["publishedAt"] == null
        ? null
        : DateTime.parse(json["publishedAt"]),
    expiresAt: json["expiresAt"] == null
        ? null
        : DateTime.parse(json["expiresAt"]),
    price: json["price"],
    isCompleted: json["isCompleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "publishedAt": publishedAt?.toIso8601String(),
    "expiresAt": expiresAt?.toIso8601String(),
    "price": price,
    "isCompleted": isCompleted,
  };
}

class Rating {
  final double? average;
  final int? ratersCount;

  Rating({this.average, this.ratersCount});

  Rating copyWith({double? average, int? ratersCount}) => Rating(
    average: average ?? this.average,
    ratersCount: ratersCount ?? this.ratersCount,
  );

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    average: json["average"]?.toDouble(),
    ratersCount: json["ratersCount"],
  );

  Map<String, dynamic> toJson() => {
    "average": average,
    "ratersCount": ratersCount,
  };
}

class Revenue {
  final int? beforePercentage;
  final int? teacherRevenue;
  final int? adminRevenue;
  final int? teacherPercentage;
  final int? adminPercentage;

  Revenue({
    this.beforePercentage,
    this.teacherRevenue,
    this.adminRevenue,
    this.teacherPercentage,
    this.adminPercentage,
  });

  Revenue copyWith({
    int? beforePercentage,
    int? teacherRevenue,
    int? adminRevenue,
    int? teacherPercentage,
    int? adminPercentage,
  }) => Revenue(
    beforePercentage: beforePercentage ?? this.beforePercentage,
    teacherRevenue: teacherRevenue ?? this.teacherRevenue,
    adminRevenue: adminRevenue ?? this.adminRevenue,
    teacherPercentage: teacherPercentage ?? this.teacherPercentage,
    adminPercentage: adminPercentage ?? this.adminPercentage,
  );

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
    beforePercentage: json["beforePercentage"],
    teacherRevenue: json["teacherRevenue"],
    adminRevenue: json["adminRevenue"],
    teacherPercentage: json["teacherPercentage"],
    adminPercentage: json["adminPercentage"],
  );

  Map<String, dynamic> toJson() => {
    "beforePercentage": beforePercentage,
    "teacherRevenue": teacherRevenue,
    "adminRevenue": adminRevenue,
    "teacherPercentage": teacherPercentage,
    "adminPercentage": adminPercentage,
  };
}

class Invoice {
  final String? currency;
  final String? timezone;
  final List<InvoiceCourse>? courses;
  final Summary? summary;

  Invoice({this.currency, this.timezone, this.courses, this.summary});

  Invoice copyWith({
    String? currency,
    String? timezone,
    List<InvoiceCourse>? courses,
    Summary? summary,
  }) => Invoice(
    currency: currency ?? this.currency,
    timezone: timezone ?? this.timezone,
    courses: courses ?? this.courses,
    summary: summary ?? this.summary,
  );

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    currency: json["currency"],
    timezone: json["timezone"],
    courses: json["courses"] == null
        ? []
        : List<InvoiceCourse>.from(
            json["courses"]!.map((x) => InvoiceCourse.fromJson(x)),
          ),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "timezone": timezone,
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class InvoiceCourse {
  final List<LineItem>? lineItems;
  final Summary? summary;

  InvoiceCourse({this.lineItems, this.summary});

  InvoiceCourse copyWith({List<LineItem>? lineItems, Summary? summary}) =>
      InvoiceCourse(
        lineItems: lineItems ?? this.lineItems,
        summary: summary ?? this.summary,
      );

  factory InvoiceCourse.fromJson(Map<String, dynamic> json) => InvoiceCourse(
    lineItems: json["lineItems"] == null
        ? []
        : List<LineItem>.from(
            json["lineItems"]!.map((x) => LineItem.fromJson(x)),
          ),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "lineItems": lineItems == null
        ? []
        : List<dynamic>.from(lineItems!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class LineItem {
  final int? coursePrice;
  final int? subscribersCount;
  final int? uniqueSubscribersCount;
  final Discount? discount;
  final int? subtotal;
  final int? teacherPercentage;
  final int? teacherRevenue;
  final int? platformRevenue;

  LineItem({
    this.coursePrice,
    this.subscribersCount,
    this.uniqueSubscribersCount,
    this.discount,
    this.subtotal,
    this.teacherPercentage,
    this.teacherRevenue,
    this.platformRevenue,
  });

  LineItem copyWith({
    int? coursePrice,
    int? subscribersCount,
    int? uniqueSubscribersCount,
    Discount? discount,
    int? subtotal,
    int? teacherPercentage,
    int? teacherRevenue,
    int? platformRevenue,
  }) => LineItem(
    coursePrice: coursePrice ?? this.coursePrice,
    subscribersCount: subscribersCount ?? this.subscribersCount,
    uniqueSubscribersCount:
        uniqueSubscribersCount ?? this.uniqueSubscribersCount,
    discount: discount ?? this.discount,
    subtotal: subtotal ?? this.subtotal,
    teacherPercentage: teacherPercentage ?? this.teacherPercentage,
    teacherRevenue: teacherRevenue ?? this.teacherRevenue,
    platformRevenue: platformRevenue ?? this.platformRevenue,
  );

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
    coursePrice: json["coursePrice"],
    subscribersCount: json["subscribersCount"],
    uniqueSubscribersCount: json["uniqueSubscribersCount"],
    discount: json["discount"] == null
        ? null
        : Discount.fromJson(json["discount"]),
    subtotal: json["subtotal"],
    teacherPercentage: json["teacherPercentage"],
    teacherRevenue: json["teacherRevenue"],
    platformRevenue: json["platformRevenue"],
  );

  Map<String, dynamic> toJson() => {
    "coursePrice": coursePrice,
    "subscribersCount": subscribersCount,
    "uniqueSubscribersCount": uniqueSubscribersCount,
    "discount": discount?.toJson(),
    "subtotal": subtotal,
    "teacherPercentage": teacherPercentage,
    "teacherRevenue": teacherRevenue,
    "platformRevenue": platformRevenue,
  };
}

class Discount {
  final int? percentage;
  final int? amountPerSubscriber;
  final int? totalAmount;
  final int? courseAmountPerSubscriber;
  final int? codeAmountPerSubscriber;

  Discount({
    this.percentage,
    this.amountPerSubscriber,
    this.totalAmount,
    this.courseAmountPerSubscriber,
    this.codeAmountPerSubscriber,
  });

  Discount copyWith({
    int? percentage,
    int? amountPerSubscriber,
    int? totalAmount,
    int? courseAmountPerSubscriber,
    int? codeAmountPerSubscriber,
  }) => Discount(
    percentage: percentage ?? this.percentage,
    amountPerSubscriber: amountPerSubscriber ?? this.amountPerSubscriber,
    totalAmount: totalAmount ?? this.totalAmount,
    courseAmountPerSubscriber:
        courseAmountPerSubscriber ?? this.courseAmountPerSubscriber,
    codeAmountPerSubscriber:
        codeAmountPerSubscriber ?? this.codeAmountPerSubscriber,
  );

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
    percentage: json["percentage"],
    amountPerSubscriber: json["amountPerSubscriber"],
    totalAmount: json["totalAmount"],
    courseAmountPerSubscriber: json["courseAmountPerSubscriber"],
    codeAmountPerSubscriber: json["codeAmountPerSubscriber"],
  );

  Map<String, dynamic> toJson() => {
    "percentage": percentage,
    "amountPerSubscriber": amountPerSubscriber,
    "totalAmount": totalAmount,
    "courseAmountPerSubscriber": courseAmountPerSubscriber,
    "codeAmountPerSubscriber": codeAmountPerSubscriber,
  };
}

class Summary {
  final int? totalSubscribers;
  final int? uniqueSubscribersCount;
  final int? totalDiscount;
  final int? totalRevenues;
  final int? teacherRevenue;
  final int? platformRevenue;

  Summary({
    this.totalSubscribers,
    this.uniqueSubscribersCount,
    this.totalDiscount,
    this.totalRevenues,
    this.teacherRevenue,
    this.platformRevenue,
  });

  Summary copyWith({
    int? totalSubscribers,
    int? uniqueSubscribersCount,
    int? totalDiscount,
    int? totalRevenues,
    int? teacherRevenue,
    int? platformRevenue,
  }) => Summary(
    totalSubscribers: totalSubscribers ?? this.totalSubscribers,
    uniqueSubscribersCount:
        uniqueSubscribersCount ?? this.uniqueSubscribersCount,
    totalDiscount: totalDiscount ?? this.totalDiscount,
    totalRevenues: totalRevenues ?? this.totalRevenues,
    teacherRevenue: teacherRevenue ?? this.teacherRevenue,
    platformRevenue: platformRevenue ?? this.platformRevenue,
  );

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalSubscribers: json["totalSubscribers"],
    uniqueSubscribersCount: json["uniqueSubscribersCount"],
    totalDiscount: json["totalDiscount"],
    totalRevenues: json["totalRevenues"],
    teacherRevenue: json["teacherRevenue"],
    platformRevenue: json["platformRevenue"],
  );

  Map<String, dynamic> toJson() => {
    "totalSubscribers": totalSubscribers,
    "uniqueSubscribersCount": uniqueSubscribersCount,
    "totalDiscount": totalDiscount,
    "totalRevenues": totalRevenues,
    "teacherRevenue": teacherRevenue,
    "platformRevenue": platformRevenue,
  };
}

class Totals {
  final int? grossRevenue;
  final int? teacherRevenue;
  final int? adminRevenue;
  final int? subscribersCount;

  Totals({
    this.grossRevenue,
    this.teacherRevenue,
    this.adminRevenue,
    this.subscribersCount,
  });

  Totals copyWith({
    int? grossRevenue,
    int? teacherRevenue,
    int? adminRevenue,
    int? subscribersCount,
  }) => Totals(
    grossRevenue: grossRevenue ?? this.grossRevenue,
    teacherRevenue: teacherRevenue ?? this.teacherRevenue,
    adminRevenue: adminRevenue ?? this.adminRevenue,
    subscribersCount: subscribersCount ?? this.subscribersCount,
  );

  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
    grossRevenue: json["grossRevenue"],
    teacherRevenue: json["teacherRevenue"],
    adminRevenue: json["adminRevenue"],
    subscribersCount: json["subscribersCount"],
  );

  Map<String, dynamic> toJson() => {
    "grossRevenue": grossRevenue,
    "teacherRevenue": teacherRevenue,
    "adminRevenue": adminRevenue,
    "subscribersCount": subscribersCount,
  };
}
