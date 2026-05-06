import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodaysSettings extends StatefulWidget {
  const TodaysSettings({super.key});

  @override
  State<TodaysSettings> createState() => _TodaysSettingsState();
}

class _TodaysSettingsState extends State<TodaysSettings> {
  List<Map<String, dynamic>> doctors = [];
  Timer? timer;

  String hospitalId = "default";

  @override
  void initState() {
    super.initState();
    loadHospital();
    updateStatus();

    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updateStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    searchCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    super.dispose();
  }

  void loadHospital() async {
    final prefs = await SharedPreferences.getInstance();
    hospitalId = prefs.getString('currentHospital') ?? "default";
    loadDoctors();
  }

  void loadDoctors() async {
    final hospitalKey = hospitalId.trim().toLowerCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('doctors')
        .get(const GetOptions(source: Source.server));

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    for (var doctor in data) {
      doctor['status'] ??= "Not Started";
      doctor['startTime'] ??= null;
      doctor['endTime'] ??= null;
      doctor['shift'] ??= "Morning";
      doctor['active'] ??= false;
      doctor['serialStart'] ??= 1;
      doctor['nowServing'] ??= 0;
      doctor['paused'] ??= false;
    }

    setState(() {
      doctors = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> saveTodaySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hospitalKey = hospitalId.trim().toLowerCase();

    prefs.setString(
      'today_settings_$hospitalKey',
      jsonEncode(doctors),
    );

    final ref = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('today_settings');

    ///  delete old data
    final snapshot = await ref.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    ///  add fresh data
    for (var doc in doctors) {
      if (doc['name'] == null || doc['name'].toString().trim().isEmpty) continue;

      await ref.doc(doc['name'].toString().trim()).set(doc);
    }
  }

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String status = "Not Started";
  String shift = "Morning";

  TextEditingController startCtrl = TextEditingController();
  TextEditingController endCtrl = TextEditingController();

  TextEditingController searchCtrl = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = doctors.where((doctor) {
      final name = (doctor['name'] ?? "").toLowerCase();
      return name.contains(searchText);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Today's Settings",
          style: app_textstyles.appBarTitle.copyWith(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: "Search Doctor",
                    hintStyle: TextStyle(
                      color: AppColors.hint_text,
                      fontSize: 16,
                    ),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.card_primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),

              SizedBox(height: 15),

              Text(
                "Date: $todayDate",
                style: app_textstyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),

              Text(
                "Active Doctors",
                style: app_textstyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  Color statusColor = Colors.grey;

                  if (doctor['status'] == "Running") {
                    statusColor = Colors.green;
                  } else if (doctor['status'] == "Paused") {
                    statusColor = Colors.orange;
                  } else if (doctor['status'] == "Finished") {
                    statusColor = Colors.red;
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),

                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.2),
                        ],
                      ),

                      border: Border.all(

                        color: doctor['status'] == "Running"
                            ? Colors.green
                            : doctor['status'] == "Paused"
                            ? Colors.orange
                            : doctor['status'] == "Finished"
                            ? Colors.red
                            : doctor['active'] == true
                            ? AppColors.card_highlight
                            : Colors.transparent,
                        width: 2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 4,
                          offset: Offset(-2, -2),
                        ),
                      ],
                    ),




                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: doctor['active'] ?? false,
                              activeColor: AppColors.icon_color,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                setState(() {
                                  doctor['active'] = value;

                                  if (value == true) {
                                    doctor['status'] = "Not Started";
                                  } else {
                                    doctor['status'] = "Off Duty";
                                  }
                                });

                                saveTodaySettings();
                              },
                            ),
                            Text(
                              doctor['name'] ?? '',
                              style: app_textstyles.appBarTitle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 5),

                        Row(
                          children: [
                            Text("Shift : "),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: doctor['shift'] ?? "Morning",
                              items: ["Morning", "Evening"]
                                  .map(
                                    (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ),
                              )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  doctor['shift'] = value;
                                });
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        /// START TIME
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Start : ${doctor['startTime'] != null ? formatTime(doctor['startTime']) : '--'}",
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (picked != null) {
                                  setState(() {
                                    doctor['startTime'] =
                                    "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
                                  });
                                  saveTodaySettings();
                                }
                              },
                              child: Text("Select",style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        /// END TIME
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "End : ${doctor['endTime'] != null ? formatTime(doctor['endTime']) : '--'}",
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (picked != null) {
                                  setState(() {
                                    doctor['endTime'] =
                                    "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
                                  });
                                  saveTodaySettings();
                                }
                              },
                              child: Text("Select",style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Status : ${doctor['status']}",
                          style: app_textstyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),

                        SizedBox(height: 5),
                        Text("Serial Start: ${doctor['serialStart']}"),
                        Text("Now Serving: ${doctor['nowServing']}"),

                        SizedBox(height: 10),

                        /// FIXED BUTTON SPACING
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: (doctor['status'] != "Running")
                                      ? null
                                      : () {
                                    setState(() {
                                      doctor['paused'] = true;
                                      doctor['status'] = "Paused";
                                    });
                                    saveTodaySettings();
                                  },
                                  child: Text("Pause"),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: (doctor['status'] != "Paused")
                                      ? null
                                      : () {
                                    setState(() {
                                      doctor['paused'] = false;
                                      doctor['status'] = "Running";
                                    });
                                    saveTodaySettings();
                                  },
                                  child: Text("Resume"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (int i = 0; i < doctors.length; i++) {
                        doctors[i]['nowServing'] =
                        doctors[i]['serialStart'];
                      }
                    });
                    saveTodaySettings();
                  },
                  child: Text("Reset",style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs =
                    await SharedPreferences.getInstance();

                    final hospitalKey = hospitalId.trim().toLowerCase();

                    prefs.setString(
                        'today_settings_$hospitalKey',
                        jsonEncode(doctors));
                    prefs.setString(
                        'doctors_$hospitalKey',
                        jsonEncode(doctors));
                  },
                  child: Text("Save",style: TextStyle(color: Colors.white,)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateStatus() {
    for (var doctor in doctors) {
      if (doctor['active'] == false) {
        doctor['status'] = "Off Duty";
        continue;
      }

      if (doctor['paused'] == true) {
        doctor['status'] = "Paused";
        continue;
      }

      if (doctor['startTime'] == null || doctor['endTime'] == null) {
        doctor['status'] = "Not Started";
        continue;
      }

      TimeOfDay start = parseTime(doctor['startTime']);
      TimeOfDay end = parseTime(doctor['endTime']);
      final now = TimeOfDay.now();

      int nowMin = now.hour * 60 + now.minute;
      int startMin = start.hour * 60 + start.minute;
      int endMin = end.hour * 60 + end.minute;

      if (nowMin < startMin) {
        doctor['status'] = "Not Started";
      } else if (nowMin <= endMin) {
        doctor['status'] = "Running";
      } else {
        doctor['status'] = "Finished";
      }
    }

    setState(() {});
  }

  TimeOfDay parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String formatTime(String time) {
    final t = parseTime(time);
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt);
  }
}