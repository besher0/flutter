// To parse this JSON data, do
//
//     final teacherWithdrawalModel = teacherWithdrawalModelFromJson(jsonString);

import 'dart:convert';

TeacherWithdrawalModel teacherWithdrawalModelFromJson(String str) =>
    TeacherWithdrawalModel.fromJson(json.decode(str));

String teacherWithdrawalModelToJson(TeacherWithdrawalModel data) =>
    json.encode(data.toJson());

class TeacherWithdrawalModel {
  final double? teacherEarnings;
  final int? withdrawnAmount;
  final double? remainingAmount;
  final List<Withdrawal>? withdrawals;
  final Pagination? pagination;

  TeacherWithdrawalModel({
    this.teacherEarnings,
    this.withdrawnAmount,
    this.remainingAmount,
    this.withdrawals,
    this.pagination,
  });

  TeacherWithdrawalModel copyWith({
    double? teacherEarnings,
    int? withdrawnAmount,
    double? remainingAmount,
    List<Withdrawal>? withdrawals,
    Pagination? pagination,
  }) => TeacherWithdrawalModel(
    teacherEarnings: teacherEarnings ?? this.teacherEarnings,
    withdrawnAmount: withdrawnAmount ?? this.withdrawnAmount,
    remainingAmount: remainingAmount ?? this.remainingAmount,
    withdrawals: withdrawals ?? this.withdrawals,
    pagination: pagination ?? this.pagination,
  );

  factory TeacherWithdrawalModel.fromJson(Map<String, dynamic> json) =>
      TeacherWithdrawalModel(
        teacherEarnings: json["teacherEarnings"]?.toDouble(),
        withdrawnAmount: json["withdrawnAmount"],
        remainingAmount: json["remainingAmount"]?.toDouble(),
        withdrawals: json["withdrawals"] == null
            ? []
            : List<Withdrawal>.from(
                json["withdrawals"]!.map((x) => Withdrawal.fromJson(x)),
              ),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "teacherEarnings": teacherEarnings,
    "withdrawnAmount": withdrawnAmount,
    "remainingAmount": remainingAmount,
    "withdrawals": withdrawals == null
        ? []
        : List<dynamic>.from(withdrawals!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  final int? page;
  final int? limit;
  final int? total;

  Pagination({this.page, this.limit, this.total});

  Pagination copyWith({int? page, int? limit, int? total}) => Pagination(
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
  };
}

class Withdrawal {
  final String? id;
  final int? amount;
  final String? status;
  final DateTime? createdAt;

  Withdrawal({this.id, this.amount, this.status, this.createdAt});

  Withdrawal copyWith({
    String? id,
    int? amount,
    String? status,
    DateTime? createdAt,
  }) => Withdrawal(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
    id: json["id"],
    amount: json["amount"],
    status: json["status"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "amount": amount,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
  };
}
