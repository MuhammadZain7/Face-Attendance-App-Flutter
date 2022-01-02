// To parse this JSON data, do
//
//     final attendanceModel = attendanceModelFromJson(jsonString);

import 'dart:convert';

AttendanceModel attendanceModelFromJson(String str) =>
    AttendanceModel.fromJson(json.decode(str));

String attendanceModelToJson(AttendanceModel data) =>
    json.encode(data.toJson());

class AttendanceModel {
  AttendanceModel({
    required this.atdId,
    required this.teacherId,
    required this.classId,
    required this.stdId,
    required this.atdDate,
    required this.stdName,
    required this.stdRollNo,
    required this.stdEmail,
    required this.stdPhone,
    required this.stdPhoto,
  });

  String atdId;
  String teacherId;
  String classId;
  String stdId;
  String atdDate;
  String stdName;
  String stdRollNo;
  String stdEmail;
  String stdPhone;
  String stdPhoto;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        atdId: json["atd_id"],
        teacherId: json["teacher_id"],
        classId: json["class_id"],
        stdId: json["std_id"],
        atdDate: json["atd_date"],
        stdName: json["std_name"],
        stdRollNo: json["std_roll_no"],
        stdEmail: json["std_email"],
        stdPhone: json["std_phone"],
        stdPhoto: json["std_photo"],
      );

  Map<String, dynamic> toJson() => {
        "atd_id": atdId,
        "teacher_id": teacherId,
        "class_id": classId,
        "std_id": stdId,
        "atd_date": atdDate,
        "std_name": stdName,
        "std_roll_no": stdRollNo,
        "std_email": stdEmail,
        "std_phone": stdPhone,
        "std_photo": stdPhoto,
      };
}
