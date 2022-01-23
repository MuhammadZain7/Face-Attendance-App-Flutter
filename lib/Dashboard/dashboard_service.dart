import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
import 'package:sms/Utils/constants.dart';
import 'package:uuid/uuid.dart';

import 'package:path_provider/path_provider.dart' as path_provider;

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
        '$classId XXX ${response.statusCode} XXX   Identify Class XXX ${response.body}');
    if (response.statusCode == 200) {
      var a = jsonDecode(response.body);
      List<IdentifyModel> identifyModel =
          List.from(a).map((e) => IdentifyModel.fromJson(e)).toList();

      for (var element in identifyModel) {
        if (element.candidates != null &&
            element.candidates!.isNotEmpty &&
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

  Future<List<Candidate>> identifyImageForAddPerson(
      classId, List<DetectionModel> detectedFace) async {
    List<Candidate> identifiedStudent = [];

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
        '$classId XXX ${response.statusCode} XXX   Identify Class XXX ${response.body}');
    if (response.statusCode == 200) {
      var a = jsonDecode(response.body);
      List<IdentifyModel> identifyModel =
          List.from(a).map((e) => IdentifyModel.fromJson(e)).toList();

      for (var element in identifyModel) {
        if (element.candidates != null &&
            element.candidates!.isNotEmpty &&
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
    } else if (response.statusCode == 403) {
      Fluttertoast.showToast(
          msg: "Out of call volume quota. Quota will be replenished in 2 days.",
          toastLength: Toast.LENGTH_LONG);
      return [];
    } else if (response.statusCode == 429) {
      Fluttertoast.showToast(
          msg: "Rate limit is exceeded. Try again in 26 seconds.",
          toastLength: Toast.LENGTH_LONG);
      return [];
    } else {
      Fluttertoast.showToast(
          msg: "Error in Face", toastLength: Toast.LENGTH_LONG);
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

  addStudentInClass(classId, className, classCode, stdName, email, phone,
      rollNo, File photo) async {
    List<DetectionModel> faceList = await detectFacesFromImage(photo);
    if (faceList.isEmpty) {
      Fluttertoast.showToast(
          msg: "No Face Found", toastLength: Toast.LENGTH_LONG);
      return;
    }
    if (faceList.length > 1) {
      Fluttertoast.showToast(
          msg: "Multiple Face Detected Kindly Add 1 Face",
          toastLength: Toast.LENGTH_LONG);
      return;
    }
    List<Candidate> identifyFaces =
        await identifyImageForAddPerson(classId, faceList);

    if (identifyFaces.isNotEmpty) {
      Fluttertoast.showToast(
          msg: "This Student is already have in this class",
          toastLength: Toast.LENGTH_LONG);
      return;
    }

    String? stdID = await addPerson(classId, stdName);
    if (stdID == null) {
      Fluttertoast.showToast(
          msg: "Student Id Null", toastLength: Toast.LENGTH_LONG);
      log("Student Id Null");
      return;
    }
    String? faceID = await addFaceInPerson(classId, stdID, stdName, photo);
    if (faceID == null) {
      Fluttertoast.showToast(msg: "Face Id Null");
      log("Face Id Null");

      return;
    }
    String? photoUrl = await uploadFile(await compressFile(photo), stdID);
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
        className: className,
        classCode: classCode,
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

  Future<File> compressFile(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        dir.absolute.path + "/${DateTime.now().microsecondsSinceEpoch}temp.jpg";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,

      // rotate: 180,
    );
    Fluttertoast.showToast(
        msg:
            "Before Size ${file.lengthSync()}  XXX After Size ${result!.lengthSync()}",
        toastLength: Toast.LENGTH_LONG);
    log("Before Size ${file.lengthSync()}");
    log("After Size ${result.lengthSync()}");

    return result;
  }

  addClass(ClassModel classModel) async {
    var aa = await classes.add(classModel.toJson());
  }

  addAttendance(List<StudentModel> list,String classId) async {
    String date = DateTime.now().microsecondsSinceEpoch.toString();
    var now = DateTime.now();
    var nowKey = "${now.year}_${now.month}_${now.day}";

    List<AttendanceModel> attendanceList = [];
    await attendance
        // .orderBy("name", descending: true)
        .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
        .where("class_id", isEqualTo: classId)
        .get()
        .then((value) {
      attendanceList = List.from(value.docs)
          .map((e) => AttendanceModel.fromJson(e.data()))
          .toList();
    });
    print('${attendanceList.toString()}');
    for (var element in list) {
      List<AttendanceModel> a = attendanceList
          .where((std) => std.stdId == element.stdId && nowKey == std.atdKey)
          .toList();
      if (a.isEmpty) {
        AttendanceModel attendanceModel = AttendanceModel(
            atdDate: date,
            atdId: Uuid().v1(),
            classId: element.classId,
            stdEmail: element.email,
            stdId: element.stdId,
            stdName: element.name,
            stdPhone: element.phone,
            stdPhoto: element.photo,
            atdKey: nowKey,
            stdRollNo: element.rollNo,
            teacherId: element.teacherId);
        var aa = await attendance.add(attendanceModel.toJson());
        showSnackBar("Attendance Marked Successfully");
      } else {
        print('${element.name} Attendance Already Marked');
        showSnackBar('${element.name} Attendance Already Marked');
      }
    }
  }

  Future<List<AttendanceModel>> getAttendanceByStd(
      classId, stdId, teacherId) async {
    List<AttendanceModel> attendanceList = [];

    await attendance
        // .orderBy("name", descending: true)
        .where("teacher_id", isEqualTo: teacherId)
        .where("class_id", isEqualTo: classId)
        .where("std_id", isEqualTo: stdId)
        .get()
        .then((value) {
      attendanceList = List.from(value.docs)
          .map((e) => AttendanceModel.fromJson(e.data()))
          .toList();
    });
    return attendanceList;
  }

  Stream<QuerySnapshot> getClasses() {
    // log("UID ${firebaseAuth.currentUser?.uid ?? "Null"}");
    return classes
        // .orderBy("category_name", descending: true)
        .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getStudentByEmail(StudentModel studentModel) {
    // log("UID ${firebaseAuth.currentUser?.uid ?? "Null"}");
    return students
        // .orderBy("category_name", descending: true)
        .where("email", isEqualTo: studentModel.email)
        // .where("roll_no", isEqualTo: studentModel.rollNo)
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

  Stream<QuerySnapshot> getAttendanceByDate(classId, DateTime dateTime) {
    String dateKey = "${dateTime.year}_${dateTime.month}_${dateTime.day}";
    return attendance
        // .orderBy("name", descending: true)
        .where("teacher_id", isEqualTo: firebaseAuth.currentUser!.uid)
        .where("class_id", isEqualTo: classId)
        .where("atd_key", isEqualTo: dateKey)
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
