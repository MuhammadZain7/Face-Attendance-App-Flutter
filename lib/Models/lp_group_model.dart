// To parse this JSON data, do
//
//     final lpGroup = lpGroupFromJson(jsonString);

import 'dart:convert';

LpGroupModel lpGroupFromJson(String str) =>
    LpGroupModel.fromJson(json.decode(str));

String lpGroupToJson(LpGroupModel data) => json.encode(data.toJson());

class LpGroupModel {
  LpGroupModel({
    required this.largePersonGroupId,
    required this.name,
    this.userData,
  });

  String largePersonGroupId;
  String name;
  String? userData;

  factory LpGroupModel.fromJson(Map<String, dynamic> json) => LpGroupModel(
        largePersonGroupId: json["largePersonGroupId"],
        name: json["name"],
        userData: json["userData"],
      );

  Map<String, dynamic> toJson() => {
        "largePersonGroupId": largePersonGroupId,
        "name": name,
        "userData": userData,
      };
}
