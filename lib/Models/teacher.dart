// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<TeacherModel> userFromJson(String str) =>
    List<TeacherModel>.from(json.decode(str).map((x) => TeacherModel.fromJson(x)));

String userToJson(List<TeacherModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TeacherModel {
  TeacherModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.password,
      required this.status,
      required this.timeStamp });

  String id;
  String name;
  String email;
  String password;
  String status;
  int timeStamp;

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        status: json["status"],
        password: json["password"],
        timeStamp: json["time_stamp"],
      );

  List<TeacherModel> listFromJson(response) {
    List<TeacherModel> list = json
        .decode(response.body)
        .map((data) => TeacherModel.fromJson(data))
        .toList();
    return list;
  }

  List<TeacherModel> listFromJson2(response) {
    List<TeacherModel> list =
        response.map((data) => TeacherModel.fromJson(data)).toList();
    return list;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "status": status,
        "password": password,
        "time_stamp": timeStamp,
      };
}
