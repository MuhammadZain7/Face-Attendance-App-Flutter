import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:sms/Authentication/auth_services.dart';
import 'package:encrypt/encrypt.dart' as EncryptPack;

import 'package:dio/dio.dart' as dios;
import 'package:sms/Dashboard/Screens/dashboard_screen.dart';
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

  @override
  void onInit() {
    super.onInit();
    if (auth.currentUser?.uid != null) {
      user = getUserFromStorage();
      WidgetsBinding.instance!.addPostFrameCallback(
          (_) => Get.offAllNamed(DashboardScreen.routeName));
    }
  }

  getUser(email, password) async {
    QuerySnapshot user = await teachers
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get();
    log('User Doc ${user.docs}');
    if (user.docs.isEmpty) {
      showSnackBar("User Data Not Found");
      logOut();
      return;
    }

    TeacherModel userModel =
        TeacherModel.fromJson(user.docs.first.data() as Map<String, dynamic>);
    setUser(userModel);
    setKey(auth.currentUser!.uid);
    Get.offAllNamed(DashboardScreen.routeName);
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
          status: "enable",
          timeStamp: DateTime.now().microsecondsSinceEpoch);
      teachers
          .doc(userCredential.user!.uid)
          .set(userModel.toJson())
          .then((value) {
        setKey(userModel.id);
        setUser(userModel);
        Get.offNamed(DashboardScreen.routeName);
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

  setKey(String key) {
    GetStorage().write("api_key", key);
  }
}
