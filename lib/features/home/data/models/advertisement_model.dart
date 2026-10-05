// To parse this JSON data, do
//
//     final advertisement = advertisementFromJson(jsonString);

import 'dart:convert';

import 'home_response_model.dart';

List<Advertisement> advertisementFromJson(List<dynamic> data) =>
    List<Advertisement>.from(data.map((x) => Advertisement.fromJson(x)));

String advertisementToJson(List<Advertisement> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
