// To parse this JSON data, do
//
//     final classModel = classModelFromJson(jsonString);

import 'dart:convert';

List<ClassModel> classModelFromJson(String str) =>
    List<ClassModel>.from(json.decode(str).map((x) => ClassModel.fromJson(x)));

String classModelToJson(List<ClassModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClassModel {
  ClassModel({
    required this.classId,
    required this.teacherId,
    required this.status,
    required this.createdDate,
    required this.className,
    required this.classCode,
  });

  String classId;
  String teacherId;
  String status;
  String createdDate;
  String className;
  String classCode;

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        classId: json["class_id"],
        teacherId: json["teacher_id"],
        status: json["status"],
        createdDate: json["created_date"],
        className: json["class_name"],
        classCode: json["class_code"],
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "teacher_id": teacherId,
        "status": status,
        "created_date": createdDate,
        "class_name": className,
        "class_code": classCode,
      };
}
