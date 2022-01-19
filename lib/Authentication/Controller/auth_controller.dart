import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sms/Authentication/Views/profile_status.dart';

import 'package:sms/Authentication/auth_services.dart';
import 'package:encrypt/encrypt.dart' as EncryptPack;

import 'package:dio/dio.dart' as dios;
import 'package:sms/Dashboard/Screens/dashboard_screen.dart';
import 'package:sms/Dashboard/StudentScreens/view_student_classes.dart';
import 'package:sms/Models/student_model.dart';
import 'package:sms/Models/teacher.dart';
import 'package:sms/Utils/constants.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  TeacherModel? user;
  bool isLoading = false;
  final _fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference teachers =
      FirebaseFirestore.instance.collection('teachers');
  CollectionReference students =
      FirebaseFirestore.instance.collection('students');

  @override
  void onInit() {
    initt();
    super.onInit();
  }

  initt() async {
    if (auth.currentUser?.uid != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        user = await getUser(
            getUserFromStorage()!.email, getUserFromStorage()!.password);
        // user!.status == "enable"
        //     ? Get.offAllNamed(DashboardScreen.routeName)
        //     : Get.offAllNamed(ProfileStatus.routeName);
      });
    } else {
      StudentModel? a = getStudentFromStorage();
      if (a != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          Get.offAllNamed(ViewStudentClasses.routeName, arguments: a);
        });
      }
    }
  }

  Future<TeacherModel?> getUser(email, password) async {
    QuerySnapshot user = await teachers
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get();
    log('User Doc ${user.docs}');
    if (user.docs.isEmpty) {
      showSnackBar("User Data Not Found");
      logOut();
      return null;
    }

    TeacherModel userModel =
        TeacherModel.fromJson(user.docs.first.data() as Map<String, dynamic>);
    setUser(userModel);
    setKey(auth.currentUser!.uid);
    if (userModel.status == "enable") {
      Get.offAllNamed(DashboardScreen.routeName);
    } else {
      Get.offAllNamed(ProfileStatus.routeName);
    }
    return userModel;
  }

  Future<StudentModel?> getStudent(email, rollNo) async {
    QuerySnapshot user = await students
        .where("email", isEqualTo: email)
        .where("roll_no", isEqualTo: rollNo)
        .get();
    log('Student Doc ${user.docs}');
    if (user.docs.isEmpty) {
      showSnackBar("Enter Valid Email");
      logOut();
      return null;
    }

    StudentModel userModel =
        StudentModel.fromJson(user.docs.first.data() as Map<String, dynamic>);

    return userModel;
  }

  startLoading() {
    isLoading = true;
    update();
  }

  stopLoading() {
    isLoading = false;
    update();
  }

  login(email, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // String token = userCredential.credential!.token.toString();

      getUser(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
        showSnackBar("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
        showSnackBar("Wrong password provided for that user.");
      }
    }
  }

  registerUser(name, email, phone, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      TeacherModel userModel = TeacherModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          password: password,
          status: "disable",
          timeStamp: DateTime.now().microsecondsSinceEpoch);
      teachers
          .doc(userCredential.user!.uid)
          .set(userModel.toJson())
          .then((value) {
        setKey(userModel.id);
        setUser(userModel);
        Get.offAllNamed(ProfileStatus.routeName);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
        showSnackBar("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
        showSnackBar("The account already exists for that email.");
      }
    } catch (e) {
      print(e);
    }
  }

  String? getKey() {
    if (GetStorage().read("api_key") != null) {
      return GetStorage().read("api_key");
    } else {
      return null;
    }
  }

  TeacherModel? getUserFromStorage() {
    if (GetStorage().read("user") != null) {
      return TeacherModel.fromJson(GetStorage().read("user"));
    }
  }

  void logOut() {
    FirebaseAuth.instance.signOut();
    GetStorage().remove("api_key");
    GetStorage().remove("user");
    GetStorage().erase();
  }

  setUser(TeacherModel userModel) {
    GetStorage().write('user', userModel.toJson());
  }

  setStudent(StudentModel studentModel) {
    GetStorage().write('student', studentModel.toJson());
  }

  StudentModel? getStudentFromStorage() {
    if (GetStorage().read("student") != null) {
      return StudentModel.fromJson(GetStorage().read("student"));
    }
  }

  setKey(String key) {
    GetStorage().write("api_key", key);
  }
}
