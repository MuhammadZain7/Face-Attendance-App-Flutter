import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sms/Dashboard/Students/students_screen.dart';
import 'package:sms/Dashboard/dashboard_controller.dart';
import 'package:sms/Models/class_model.dart';
import 'package:sms/Widgets/custom_button.dart';
import 'package:sms/Widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class ClassScreen extends StatelessWidget {
  static const String routeName = "/class_screen";

  bool isSubmitLoading = false;

  ClassScreen({Key? key}) : super(key: key);
  final dashCtrl = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: dashCtrl.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.data != null &&
              snapshot.hasData &&
              snapshot.data!.docs.isNotEmpty) {
            List categories = snapshot.data!.docs;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                ClassModel categoryModel =
                    ClassModel.fromJson(categories.toList()[index].data());
                print('${snapshot.data!.docs.elementAt(index).id}');

                return Card(
                    child: InkWell(
                  onTap: () {
                    Get.toNamed(StudentsScreen.routeName,
                        arguments: categoryModel.classId);
                  },
                  child: GetBuilder<DashboardController>(builder: (_) {
                    return ListTile(
                      title: Text(categoryModel.className),
                      subtitle: Text(categoryModel.classCode),
                      trailing: isDeleting
                          ? CircularProgressIndicator()
                          : IconButton(
                              onPressed: () async {
                                isDeleting = true;
                                dashCtrl.update();
                                await dashCtrl.deleteClass(
                                    categoryModel.classId,
                                    snapshot.data!.docs.elementAt(index).id);
                                isDeleting = false;
                                dashCtrl.update();
                                Fluttertoast.showToast(msg: "Deleted Successfully");
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                            ),
                    );
                  }),
                ));
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("No Class Available"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCategory(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    TextEditingController categoryName = TextEditingController();
    TextEditingController categoryCode = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return GetBuilder<DashboardController>(builder: (_) {
            return AlertDialog(
              title: const Text('Add Class'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: "Class Name",
                      isShowBorder: true,
                      inputAction: TextInputAction.next,
                      inputType: TextInputType.text,
                      controller: categoryName,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    CustomTextField(
                      hintText: "Batch Code",
                      isShowBorder: true,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.text,
                      controller: categoryCode,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: isSubmitLoading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          btnTxt: "Add Class",
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              isSubmitLoading = true;
                              dashCtrl.update();

                              await dashCtrl.createClass(const Uuid().v1(),
                                  categoryName.text, categoryCode.text);

                              isSubmitLoading = false;
                              dashCtrl.update();
                              Navigator.pop(context);
                            }
                          },
                        ),
                ),
              ],
            );
          });
        });
  }
}
