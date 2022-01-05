import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sms/Dashboard/dashboard_controller.dart';
import 'package:sms/Models/attendance_model.dart';
import 'package:sms/Models/student_model.dart';
import 'package:sms/Utils/color_resources.dart';
import 'package:sms/Widgets/profile_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewAttendanceByStd extends StatefulWidget {
  ViewAttendanceByStd({Key? key}) : super(key: key);
  static const String routeName = "/view_attendance_by_std_screen";

  @override
  State<ViewAttendanceByStd> createState() => _ViewAttendanceByStdState();
}

class _ViewAttendanceByStdState extends State<ViewAttendanceByStd> {
  final dashCtrl = Get.find<DashboardController>();

  final StudentModel _studentModel = Get.arguments;
  DateTime startDate = DateTime.utc(2021, 1, 1);
  DateTime endDate = DateTime.now();
  DateTime focusDate = DateTime.now();

  List<AttendanceModel> _listAttendance = [];
  bool isLoading = true;
  DateTime currentSelectedMonth = DateTime.now();
  int sundayCountCurrentMonth = 0;
  int attendanceCountCurrentMonth = 0;
  int a = 0;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    loadAttendance();
    DateTime now = DateTime.now();
    currentSelectedMonth = DateTime(now.year, now.month + 1, 0);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getSundayOfMonth(currentSelectedMonth);

      // Add Your Code here.
    });

    super.initState();
  }

  loadAttendance() async {
    _listAttendance = await dashCtrl.getAttendanceByStd(
        _studentModel.classId, _studentModel.stdId);
    isLoading = false;
    log("After Load Attend Update");
    dashCtrl.update();
  }

  getSundayOfMonth(DateTime dateTime) {
    attendanceCountCurrentMonth = 0;
    sundayCountCurrentMonth = 0;
    int count = 0;
    for (int i = 1; i <= dateTime.day; i++) {
      if (DateTime(dateTime.year, dateTime.month, i).weekday ==
          DateTime.sunday) {
        ++count;
      }
    }
    print('Total Days ${dateTime.day} Sunday $count');

    sundayCountCurrentMonth = count;
    Future.delayed(const Duration(seconds: 1), () {
      log("After Get Sunday Update");
      dashCtrl.update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${_studentModel.name} Attendance"),
          leading: ProfileWidget(
            isEdit: false,
            imagePath: dashCtrl.getStudentImageUrl(_studentModel.photo),
            size: 40,
            onClicked: () {
              Get.back();
            },
          ),
        ),
        body: GetBuilder<DashboardController>(builder: (_) {
          return Column(
            children: [
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TableCalendar(
                      firstDay: startDate,
                      lastDay: endDate,
                      focusedDay: focusDate,
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        // _calendarFormat = format;
                        log("Format Change Update");
                        // attendanceCountCurrentMonth = 0;
                        // sundayCountCurrentMonth = 0;
                        // dashCtrl.update();
                      },

                      onPageChanged: (focusedDay) {
                        focusDate = focusedDay;
                        attendanceCountCurrentMonth = 0;
                        sundayCountCurrentMonth = 0;
                        currentSelectedMonth =
                            DateTime(focusedDay.year, focusedDay.month + 1, 0);
                        getSundayOfMonth(currentSelectedMonth);
                        log("Page Change Update");
                        dashCtrl.update();
                      },
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          if (day.weekday == DateTime.sunday) {
                            final text = DateFormat.E().format(day);

                            return Center(
                              child: Text(
                                text,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          if (focusDate.month != day.month) {
                            return null;
                          }
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Text(
                                day.day.toString(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else {
                            String dayKey =
                                "${day.year}_${day.month}_${day.day}";
                            List<AttendanceModel> a = _listAttendance
                                .where((std) => dayKey == std.atdKey)
                                .toList();
                            if (a.isNotEmpty) {
                              ++attendanceCountCurrentMonth;
                              print(
                                  'default ${day.day}  ${attendanceCountCurrentMonth}');
                              return textDateWidget(
                                  day, day.day.toString(), "present");
                            } else {
                              return textDateWidget(
                                  day, day.day.toString(), "absent");
                            }
                          }
                        },
                        todayBuilder: (context, day, focusedDay) {
                          if (focusDate.month != day.month) {
                            return null;
                          }
                          if (day.weekday == DateTime.sunday) {
                            return Center(
                              child: Text(
                                day.day.toString(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else {
                            String dayKey =
                                "${day.year}_${day.month}_${day.day}";
                            List<AttendanceModel> a = _listAttendance
                                .where((std) => dayKey == std.atdKey)
                                .toList();
                            if (a.isNotEmpty) {
                              ++attendanceCountCurrentMonth;
                              print(
                                  'today ${day.day} ${attendanceCountCurrentMonth}');
                              return textDateWidget(
                                  day, day.day.toString(), "present");
                            } else {
                              return textDateWidget(
                                  day, day.day.toString(), "absent");
                            }
                          }
                        },
                      ),
                    ),
              Spacer(),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Current Month Attendance",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Present ${attendanceCountCurrentMonth}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.green),
                          ),
                          Text(
                            "Absent ${(currentSelectedMonth.day - sundayCountCurrentMonth) - attendanceCountCurrentMonth}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.redAccent),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }));
  }

  Widget textDateWidget(DateTime day, text, type) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        color: type == "present" ? Colors.green : Colors.red,
        elevation: 0,
        shape: RoundedRectangleBorder(
          // side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
