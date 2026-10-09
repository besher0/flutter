// To parse this JSON data, do
//
//     final courseStatisticsModel = courseStatisticsModelFromJson(jsonString);

import 'dart:convert';

CourseStatisticsModel courseStatisticsModelFromJson(String str) =>
    CourseStatisticsModel.fromJson(json.decode(str));

String courseStatisticsModelToJson(CourseStatisticsModel data) =>
    json.encode(data.toJson());

class CourseStatisticsModel {
  final Course? course;
  final SubscriptionPrice? subscriptionPrice;
  final Subscriptions? subscriptions;
  final Rating? rating;
  final Revenue? revenue;
  final Percentages? percentages;
  final Context? context;

  CourseStatisticsModel({
    this.course,
    this.subscriptionPrice,
    this.subscriptions,
    this.rating,
    this.revenue,
    this.percentages,
    this.context,
  });

  CourseStatisticsModel copyWith({
    Course? course,
    SubscriptionPrice? subscriptionPrice,
    Subscriptions? subscriptions,
    Rating? rating,
    Revenue? revenue,
    Percentages? percentages,
    Context? context,
  }) => CourseStatisticsModel(
    course: course ?? this.course,
    subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
    subscriptions: subscriptions ?? this.subscriptions,
    rating: rating ?? this.rating,
    revenue: revenue ?? this.revenue,
    percentages: percentages ?? this.percentages,
    context: context ?? this.context,
  );

  factory CourseStatisticsModel.fromJson(
    Map<String, dynamic> json,
  ) => CourseStatisticsModel(
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
    subscriptionPrice: json["subscriptionPrice"] == null
        ? null
        : SubscriptionPrice.fromJson(json["subscriptionPrice"]),
    subscriptions: json["subscriptions"] == null
        ? null
        : Subscriptions.fromJson(json["subscriptions"]),
    rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
    revenue: json["revenue"] == null ? null : Revenue.fromJson(json["revenue"]),
    percentages: json["percentages"] == null
        ? null
        : Percentages.fromJson(json["percentages"]),
    context: json["context"] == null ? null : Context.fromJson(json["context"]),
  );

  Map<String, dynamic> toJson() => {
    "course": course?.toJson(),
    "subscriptionPrice": subscriptionPrice?.toJson(),
    "subscriptions": subscriptions?.toJson(),
    "rating": rating?.toJson(),
    "revenue": revenue?.toJson(),
    "percentages": percentages?.toJson(),
    "context": context?.toJson(),
  };
}

class Context {
  final String? role;

  Context({this.role});

  Context copyWith({String? role}) => Context(role: role ?? this.role);

  factory Context.fromJson(Map<String, dynamic> json) =>
      Context(role: json["role"]);

  Map<String, dynamic> toJson() => {"role": role};
}

class Course {
  final String? id;
  final String? name;
  final DateTime? publishedAt;
  final DateTime? expiresAt;

  Course({this.id, this.name, this.publishedAt, this.expiresAt});

  Course copyWith({
    String? id,
    String? name,
    DateTime? publishedAt,
    DateTime? expiresAt,
  }) => Course(
    id: id ?? this.id,
    name: name ?? this.name,
    publishedAt: publishedAt ?? this.publishedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    name: json["name"],
    publishedAt: json["publishedAt"] == null
        ? null
        : DateTime.parse(json["publishedAt"]),
    expiresAt: json["expiresAt"] == null
        ? null
        : DateTime.parse(json["expiresAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "publishedAt": publishedAt?.toIso8601String(),
    "expiresAt": expiresAt?.toIso8601String(),
  };
}

class Percentages {
  final int? myPercentage;
  final int? teacherPercentage;
  final int? platformPercentage;

  Percentages({
    this.myPercentage,
    this.teacherPercentage,
    this.platformPercentage,
  });

  Percentages copyWith({
    int? myPercentage,
    int? teacherPercentage,
    int? platformPercentage,
  }) => Percentages(
    myPercentage: myPercentage ?? this.myPercentage,
    teacherPercentage: teacherPercentage ?? this.teacherPercentage,
    platformPercentage: platformPercentage ?? this.platformPercentage,
  );

  factory Percentages.fromJson(Map<String, dynamic> json) => Percentages(
    myPercentage: json["myPercentage"],
    teacherPercentage: json["teacherPercentage"],
    platformPercentage: json["platformPercentage"],
  );

  Map<String, dynamic> toJson() => {
    "myPercentage": myPercentage,
    "teacherPercentage": teacherPercentage,
    "platformPercentage": platformPercentage,
  };
}

class Rating {
  final int? outOf;
  final double? average;
  final int? ratersCount;

  Rating({this.outOf, this.average, this.ratersCount});

  Rating copyWith({int? outOf, double? average, int? ratersCount}) => Rating(
    outOf: outOf ?? this.outOf,
    average: average ?? this.average,
    ratersCount: ratersCount ?? this.ratersCount,
  );

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    outOf: json["outOf"],
    average: json["average"]?.toDouble(),
    ratersCount: json["ratersCount"],
  );

  Map<String, dynamic> toJson() => {
    "outOf": outOf,
    "average": average,
    "ratersCount": ratersCount,
  };
}

class Revenue {
  final double? beforePercentage;
  final double? afterPercentage;

  Revenue({this.beforePercentage, this.afterPercentage});

  Revenue copyWith({double? beforePercentage, double? afterPercentage}) =>
      Revenue(
        beforePercentage: beforePercentage ?? this.beforePercentage,
        afterPercentage: afterPercentage ?? this.afterPercentage,
      );

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
    beforePercentage: json["beforePercentage"]?.toDouble(),
    afterPercentage: json["afterPercentage"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "beforePercentage": beforePercentage,
    "afterPercentage": afterPercentage,
  };
}

class SubscriptionPrice {
  final int? beforeDiscount;
  final int? discountPercentage;
  final int? afterDiscount;
  final bool? hasDiscount;

  /// Missing (older backends) means visible.
  final bool isPriceVisible;

  SubscriptionPrice({
    this.beforeDiscount,
    this.discountPercentage,
    this.afterDiscount,
    this.hasDiscount,
    this.isPriceVisible = true,
  });

  SubscriptionPrice copyWith({
    int? beforeDiscount,
    int? discountPercentage,
    int? afterDiscount,
    bool? hasDiscount,
    bool? isPriceVisible,
  }) => SubscriptionPrice(
    beforeDiscount: beforeDiscount ?? this.beforeDiscount,
    discountPercentage: discountPercentage ?? this.discountPercentage,
    afterDiscount: afterDiscount ?? this.afterDiscount,
    hasDiscount: hasDiscount ?? this.hasDiscount,
    isPriceVisible: isPriceVisible ?? this.isPriceVisible,
  );

  factory SubscriptionPrice.fromJson(Map<String, dynamic> json) =>
      SubscriptionPrice(
        beforeDiscount: json["beforeDiscount"],
        discountPercentage: json["discountPercentage"]?.toInt(),
        afterDiscount: json["afterDiscount"],
        hasDiscount: json["hasDiscount"],
        isPriceVisible: json["isPriceVisible"] is bool
            ? json["isPriceVisible"] as bool
            : true,
      );

  Map<String, dynamic> toJson() => {
    "beforeDiscount": beforeDiscount,
    "discountPercentage": discountPercentage,
    "afterDiscount": afterDiscount,
    "hasDiscount": hasDiscount,
    "isPriceVisible": isPriceVisible,
  };
}

class Subscriptions {
  final int? count;

  Subscriptions({this.count});

  Subscriptions copyWith({int? count}) =>
      Subscriptions(count: count ?? this.count);

  factory Subscriptions.fromJson(Map<String, dynamic> json) =>
      Subscriptions(count: json["count"]);

  Map<String, dynamic> toJson() => {"count": count};
}
