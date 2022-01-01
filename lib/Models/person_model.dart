// To parse this JSON data, do
//
//     final personModel = personModelFromJson(jsonString);

import 'dart:convert';

List<PersonModel> personModelFromJson(String str) => List<PersonModel>.from(json.decode(str).map((x) => PersonModel.fromJson(x)));

String personModelToJson(List<PersonModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PersonModel {
  PersonModel({
   required this.personId,
   required this.persistedFaceIds,
    required this.name,
    this.userData,
  });

  String personId;
  List<String> persistedFaceIds;
  String name;
  String? userData;

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    personId: json["personId"],
    persistedFaceIds: List<String>.from(json["persistedFaceIds"].map((x) => x)),
    name: json["name"],
    userData: json["userData"],
  );

  Map<String, dynamic> toJson() => {
    "personId": personId,
    "persistedFaceIds": List<dynamic>.from(persistedFaceIds.map((x) => x)),
    "name": name,
    "userData": userData,
  };
}
