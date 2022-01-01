import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Dashboard/dashboard_service.dart';
import 'package:sms/Models/detection_model.dart';

class DashboardController extends GetxController {
  final dashService = Get.find<DashboardService>();

  bool isLoading = false;
  final _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference suppliers =
      FirebaseFirestore.instance.collection('supplier');
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customer');
  CollectionReference products =
      FirebaseFirestore.instance.collection('product');

  // CollectionReference products =
  // FirebaseFirestore.instance.collection('product');

  StreamSubscription<ConnectivityResult>? subscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  Future createClass(classId, className, classCode) async {
    await dashService.createClass(classId, className, classCode);
  }

  Stream<QuerySnapshot> getClasses() {
    return dashService.getClasses();
  }

  Stream<QuerySnapshot> getStudentsByClassId(classId) {
    return dashService.getStudentsByClassId(classId);
  }

  @override
  void onInit() {
    super.onInit();
    connectionListener();
    // if (firebaseAuth.currentUser?.uid != null) getCategories();
  }

  Stream<QuerySnapshot> getCustomers() {
    // log("UID ${firebaseAuth.currentUser?.uid ?? "Null"}");
    return customers
        // .orderBy("customer_name", descending: true)
        .where("uid", isEqualTo: firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  String getStudentImageUrl(name) {
    return "https://firebasestorage.googleapis.com/v0/b/my-project-1494048213269.appspot.com/o/StudentsImages%2F$name?alt=media";
  }

  Future deleteClass(classId, fbID) async {
    return await dashService.deleteClass(classId, fbID);
  }

  Future deleteStudentFromClass(classId, stdId, fbId) async {
    return await dashService.deleteStudentFromClass(classId, stdId, fbId);
  }

  // addCategory(CategoryModel categoryModel) async {
  //   var aa = await category.add(categoryModel.toJson());
  // }
  addStudentInClass(classId, stdName, email, phone, rollNo, File photo) async {
    return dashService.addStudentInClass(
        classId, stdName, email, phone, rollNo, photo);
  }

  connectionListener() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Get.snackbar("Connections ", "");
    });
  }

  Future<List<DetectionModel>> detectFacesFromImage(File image) async {
    return await dashService.detectFacesFromImage(image);
  }

  @override
  void dispose() {
    if (subscription != null) subscription!.cancel();
  }
}
