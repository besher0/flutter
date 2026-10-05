// To parse this JSON data, do
//
//     final customerServiceModel = customerServiceModelFromJson(jsonString);

import 'dart:convert';

List<CustomerServiceModel> customerServiceListFromJson(List<dynamic> data) =>
    List<CustomerServiceModel>.from(
      data.map((json) => CustomerServiceModel.fromJson(json)).toList(),
    );
CustomerServiceModel customerServiceModelFromJson(String str) =>
    CustomerServiceModel.fromJson(json.decode(str));

String customerServiceModelToJson(CustomerServiceModel data) =>
    json.encode(data.toJson());

class CustomerServiceModel {
  final String? technicalSupportPhone;
  final String? contactSupportPhone;
  final String? whatsappUrl;
  final String? telegramUrl;
  final String? facebookUrl;
  final String? instagramUrl;

  CustomerServiceModel({
    this.technicalSupportPhone,
    this.contactSupportPhone,
    this.whatsappUrl,
    this.telegramUrl,
    this.facebookUrl,
    this.instagramUrl,
  });

  CustomerServiceModel copyWith({
    String? technicalSupportPhone,
    String? contactSupportPhone,
    String? whatsappUrl,
    String? telegramUrl,
    String? facebookUrl,
    String? instagramUrl,
  }) => CustomerServiceModel(
    technicalSupportPhone: technicalSupportPhone ?? this.technicalSupportPhone,
    contactSupportPhone: contactSupportPhone ?? this.contactSupportPhone,
    whatsappUrl: whatsappUrl ?? this.whatsappUrl,
    telegramUrl: telegramUrl ?? this.telegramUrl,
    facebookUrl: facebookUrl ?? this.facebookUrl,
    instagramUrl: instagramUrl ?? this.instagramUrl,
  );

  factory CustomerServiceModel.fromJson(Map<String, dynamic> json) =>
      CustomerServiceModel(
        technicalSupportPhone: json["technicalSupportPhone"],
        contactSupportPhone: json["contactSupportPhone"],
        whatsappUrl: json["whatsappUrl"],
        telegramUrl: json["telegramUrl"],
        facebookUrl: json["facebookUrl"],
        instagramUrl: json["instagramUrl"],
      );

  Map<String, dynamic> toJson() => {
    "technicalSupportPhone": technicalSupportPhone,
    "contactSupportPhone": contactSupportPhone,
    "whatsappUrl": whatsappUrl,
    "telegramUrl": telegramUrl,
    "facebookUrl": facebookUrl,
    "instagramUrl": instagramUrl,
  };
}
