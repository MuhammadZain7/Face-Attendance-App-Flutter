// To parse this JSON data, do
//
//     final studentModel = studentModelFromJson(jsonString);

import 'dart:convert';

StudentModel studentModelFromJson(String str) =>
    StudentModel.fromJson(json.decode(str));

String studentModelToJson(StudentModel data) => json.encode(data.toJson());

class StudentModel {
  StudentModel({
    required this.stdId,
    required this.teacherId,
    required this.classId,
    required this.className,
    required this.classCode,
    required this.stdFaceId,
    required this.name,
    required this.photo,
    required this.email,
    required this.phone,
    required this.rollNo,
    required this.createdDate,
  });

  String stdId;
  String teacherId;
  String classId;
  String className;
  String classCode;
  String stdFaceId;
  String name;
  String photo;
  String email;
  String phone;
  String rollNo;
  String createdDate;

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        stdId: json["std_id"],
        teacherId: json["teacher_id"],
        classId: json["class_id"],
        className: json["class_name"],
        classCode: json["class_code"],
        stdFaceId: json["std_face_id"],
        name: json["name"],
        photo: json["photo"],
        email: json["email"],
        phone: json["phone"],
        rollNo: json["roll_no"],
        createdDate: json["created_date"],
      );

  Map<String, dynamic> toJson() => {
        "std_id": stdId,
        "teacher_id": teacherId,
        "class_id": classId,
        "class_name": className,
        "class_code": classCode,
        "std_face_id": stdFaceId,
        "name": name,
        "photo": photo,
        "email": email,
        "phone": phone,
        "roll_no": rollNo,
        "created_date": createdDate,
      };
}
