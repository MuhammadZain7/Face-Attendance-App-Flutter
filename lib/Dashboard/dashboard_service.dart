import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sms/Models/attendance_model.dart';
import 'package:sms/Models/detection_model.dart';
import 'package:sms/Models/identify_model.dart';
import 'package:sms/Models/lp_group_model.dart';
import 'package:sms/Models/class_model.dart';
import 'package:sms/Models/student_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';

class DashboardService extends GetConnect {
  String baseURL = "https://fazecam2.cognitiveservices.azure.com/face/v1.0";
  String faceApiKey = "1e009f2a55d04277b291d3e8a61c0a72";
  final _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference classes =
      FirebaseFirestore.instance.collection('classes');

  CollectionReference students =
      FirebaseFirestore.instance.collection('students');

  CollectionReference attendance =
      FirebaseFirestore.instance.collection('attendance');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  void onInit() {}

  Future createClass(classId, className, classCode) async {
    http.Response response = await http
        .put(
      Uri.parse('$baseURL/largepersongroups/$classId'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/json"
      },
      body: jsonEncode({"name": "$className"}),
    )
        .catchError((e) {
      log('Create Class $e');
    });
    print('$classId XXX ${response.body}');
    if (response.statusCode == 200) {
      // var a = jsonDecode(response.body);

      // LpGroupModel lpGroupModel = LpGroupModel.fromJson(a);
      // return List.from(a).map((e) => Project.fromJson(e)).toList();
      await addClass(ClassModel(
          classId: classId,
          teacherId: firebaseAuth.currentUser!.uid,
          status: "enable",
          createdDate: DateTime.now().microsecondsSinceEpoch.toString(),
          className: className,
          classCode: classCode));
    } else {
      Fluttertoast.showToast(msg: "Error Create Class");
    }
  }

  Future<List<Candidate>> faceIdentification(classId, File image) async {
    List<Candidate> identifiedStudent = [];

    List<DetectionModel> detectedFace = await detectFacesFromImage(image);
    if (detectedFace.isEmpty) {
      Fluttertoast.showToast(
          msg: "No Face Found in Image", toastLength: Toast.LENGTH_LONG);
      log("No Face Found in Image");
      return [];
    }
    bool isTrained = await trainClass(classId);
    if (!isTrained) {
      Fluttertoast.showToast(
          msg: "Training Error", toastLength: Toast.LENGTH_LONG);
      log("Training Error");
      return [];
    }

    List<String> faceIds = [];
    for (var element in detectedFace) {
      faceIds.add(element.faceId);
    }

    http.Response response = await http
        .post(
      Uri.parse('$baseURL/identify'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "faceIds": faceIds,
        "personGroupId": "",
        "largePersonGroupId": classId
      }),
    )
        .catchError((e) {
      log('Identify Class $e');
    });
    print(
        '$classId XXX ${response.statusCode} XXX Error Identify Class XXX ${response.body}');
    if (response.statusCode == 200) {
      var a = jsonDecode(response.body);
      List<IdentifyModel> identifyModel =
          List.from(a).map((e) => IdentifyModel.fromJson(e)).toList();

      for (var element in identifyModel) {
        if (element.candidates != null &&
            element.candidates?.elementAt(0) != null) {
          identifiedStudent.add(element.candidates!.elementAt(0));
        }
      }
      return identifiedStudent;
    } else {
      Fluttertoast.showToast(msg: "Error Identify Class");
      return [];
    }
  }

  Future<List<StudentModel>> getStudentFromIds(
      List<Candidate> identifiedStudents) async {
    List<StudentModel> studentsList = [];
    for (var element in identifiedStudents) {
      await students
          .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
          .where("std_id", isEqualTo: element.personId)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.elementAt(0).data() != null) {
          studentsList.add(StudentModel.fromJson(
              value.docs.first.data() as Map<String, dynamic>));
        }
      });
    }
    return studentsList;
  }

  Future<bool> trainClass(classId) async {
    http.Response response = await http.post(
      Uri.parse('$baseURL/largepersongroups/$classId/train'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/json"
      },
    ).catchError((e) {
      log('Create Class $e');
    });
    log('$classId XXX ${response.body}');
    if (response.statusCode == 202 || response.statusCode == 200) {
      return true;
    } else {
      Fluttertoast.showToast(msg: "Error Train Class");
      return false;
    }
  }

  Future deleteClass(classId, fbID) async {
    http.Response response = await http.delete(
      Uri.parse('$baseURL/largepersongroups/$classId'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/json"
      },
    ).catchError((e) {
      log('Create Class $e');
    });
    print('$classId XXX ${response.body}');
    if (response.statusCode == 200) {
      await classes.doc(fbID).delete();
    } else {
      Fluttertoast.showToast(msg: "Error Delete Class");
    }
  }

  Future<List<DetectionModel>> detectFacesFromImage(File image) async {
    http.Response response = await http
        .post(
      Uri.parse('$baseURL/detect'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/octet-stream"
      },
      body: await image.readAsBytes(),
    )
        .catchError((e) {
      log('Detection Error $e');
    });
    print('${response.statusCode}  XXX ${response.body}');
    if (response.statusCode == 200) {
      return List.from(jsonDecode(response.body))
          .map((e) => DetectionModel.fromJson(e))
          .toList();
    } else {
      Fluttertoast.showToast(msg: "Error Delete Class");
      return [];
    }
  }

  Future deleteStudentFromClass(classId, stdId, fbId) async {
    http.Response response = await http.delete(
      Uri.parse('$baseURL/largepersongroups/$classId/persons/$stdId'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/json"
      },
    ).catchError((e) {
      log('Create Class $e');
    });
    print('$classId XXX ${response.body}');
    if (response.statusCode == 200) {
      await students.doc(fbId).delete();
    } else {
      Fluttertoast.showToast(msg: "Error Delete Class");
    }
  }

  Future<String?> addFaceInPerson(
      classId, personId, stdName, File photo) async {
    // largepersongroups/test1/persons/3695f2bf-afdb-4639-8f6a-f9806b78f4f0/persistedfaces?userData=Face 1&detectionModel=detection_01
    http.Response response = await http
        .post(
      Uri.parse(
          '$baseURL/largepersongroups/$classId/persons/$personId/persistedfaces'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/octet-stream"
      },
      body: await photo.readAsBytes(),
    )
        .catchError((e) {
      log('Create Person $e');
    });

    print('$classId XXX ${response.statusCode} XXX ${response.body}');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['persistedFaceId'];
    } else if (response.statusCode == 400) {
      Fluttertoast.showToast(
          msg: "No Face Detected", toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(
          msg: "Error in Add Face", toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<String?> addPerson(classId, stdName) async {
    http.Response response = await http
        .post(
      Uri.parse('$baseURL/largepersongroups/$classId/persons'),
      headers: {
        'Ocp-Apim-Subscription-Key': faceApiKey,
        "Content-Type": "application/json"
      },
      body: jsonEncode({"name": "$stdName"}),
    )
        .catchError((e) {
      log('Create Person $e');
    });
    print('$classId XXX ${response.statusCode} XXX ${response.body}');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['personId'];
    }
  }

  addStudentInClass(classId, stdName, email, phone, rollNo, File photo) async {
    String? stdID = await addPerson(classId, stdName);
    if (stdID == null) {
      Fluttertoast.showToast(msg: "Student Id Null");
      log("Student Id Null");
      return;
    }
    String? faceID = await addFaceInPerson(classId, stdID, stdName, photo);
    if (faceID == null) {
      Fluttertoast.showToast(msg: "Face Id Null");
      log("Face Id Null");

      return;
    }
    String? photoUrl = await uploadFile(photo, stdID);
    if (photoUrl == null) {
      Fluttertoast.showToast(msg: "Image Upload Error");
      log("Image Upload Error");
      return;
    }
    String date = DateTime.now().microsecondsSinceEpoch.toString();
    StudentModel studentModel = StudentModel(
        stdId: stdID,
        teacherId: firebaseAuth.currentUser!.uid,
        classId: classId,
        stdFaceId: faceID,
        name: stdName,
        photo: photoUrl,
        email: email,
        phone: phone,
        rollNo: rollNo,
        createdDate: date);
    var aa = await students.add(studentModel.toJson());
    Fluttertoast.showToast(msg: "Added Successfully");
  }

  addClass(ClassModel classModel) async {
    var aa = await classes.add(classModel.toJson());
  }

  addAttendance(List<StudentModel> list) async {
    String date = DateTime.now().microsecondsSinceEpoch.toString();
    for (var element in list) {
      AttendanceModel attendanceModel = AttendanceModel(
          atdDate: date,
          atdId: Uuid().v1(),
          classId: element.classId,
          stdEmail: element.email,
          stdId: element.stdId,
          stdName: element.name,
          stdPhone: element.phone,
          stdPhoto: element.photo,
          stdRollNo: element.rollNo,
          teacherId: element.teacherId);
      var aa = await attendance.add(attendanceModel.toJson());
    }


  }

  Stream<QuerySnapshot> getClasses() {
    // log("UID ${firebaseAuth.currentUser?.uid ?? "Null"}");
    return classes
        // .orderBy("category_name", descending: true)
        .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getStudentsByClassId(classId) {
    // log("UID ${firebaseAuth.currentUser?.uid ?? "Null"}");
    return students
        // .orderBy("name", descending: true)
        .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
        .where("class_id", isEqualTo: classId)
        .snapshots();
  }

  Stream<QuerySnapshot> getAttendance(classId) {
    // log("UID ${firebaseAuth.currentUser?.uid ?? "Null"}");
    return attendance
        // .orderBy("name", descending: true)
        .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
        .where("class_id", isEqualTo: classId)
        .snapshots();
  }

  Future<String?> uploadFile(File file, String stdId) async {
    try {
      if (kIsWeb) {
        await storage.ref("StudentsImages/$stdId.png").putData(
            await file.readAsBytes(),
            SettableMetadata(contentType: "image/png"));
      } else {
        await storage.ref("StudentsImages/$stdId.png").putFile(file);
      }
      return "$stdId.png";
    } on firebase_storage.FirebaseException catch (e) {
      log(e.message ?? "");
    }
  }
}
