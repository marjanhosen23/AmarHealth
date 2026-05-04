import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffPanel extends StatefulWidget {
  const StaffPanel({super.key});

  @override
  State<StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends State<StaffPanel> {

  String hospitalName = "";
  List<Map<String, dynamic>> todaySettings = [];

  Timer? timer;

  String formatHospitalKey(String name) {
    return name.trim().toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    loadData();

    /// AUTO UPDATE EVERY 30 SEC
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updateStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();

    hospitalName = prefs.getString('currentHospital') ?? "";
    final hospitalKey = formatHospitalKey(hospitalName);

    ///LOCAL LOAD
    final data = prefs.getString('today_settings_$hospitalKey');

    if (data != null) {
      todaySettings =
      List<Map<String, dynamic>>.from(jsonDecode(data));
    }

    /// FIREBASE LOAD
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('today_settings')
        .get();

    if (snapshot.docs.isNotEmpty) {
      todaySettings =
          snapshot.docs.map((doc) => doc.data()).toList();
    }

    setState(() {});
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hospitalKey = formatHospitalKey(hospitalName);

    prefs.setString(
      'today_settings_$hospitalKey',
      jsonEncode(todaySettings),
    );

    /// FIREBASE SAVE
    for (var doc in todaySettings) {
      await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .collection('today_settings')
          .doc(doc['name'])
          .set(doc);
    }
  }

  void nextPatient(int index) {
    setState(() {
      todaySettings[index]['nowServing']++;
    });
    saveSettings();
  }

  /// AUTO STATUS UPDATE
  void updateStatus() {
    final now = TimeOfDay.now();

    for (var doctor in todaySettings) {

      if (doctor['startTime'] == null || doctor['endTime'] == null) {
        doctor['status'] = "Not Started";
        continue;
      }

      final start = parseTime(doctor['startTime']);
      final end = parseTime(doctor['endTime']);

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

    saveSettings();
    setState(() {});
  }

  /// TIME PARSER
  TimeOfDay parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Staff Panel",style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: Theme.of(context).primaryColor,
      ),

      body: todaySettings.isEmpty
          ? const Center(child: Text("No data found"))
          : ListView.builder(
        itemCount: todaySettings.length,
        itemBuilder: (context, index) {

          final data = todaySettings[index];

          final name = data['name'] ?? "Doctor";
          final shift = data['shift'] ?? "N/A";
          final start = data['startTime'] ?? "--";
          final end = data['endTime'] ?? "--";
          final nowServing = data['nowServing'] ?? 0;
          final status = data['status'] ?? "Not Started";

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),

              // glass look
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.card_primary.withOpacity(0.6),
                  AppColors.card_primary.withOpacity(0.2),
                ],
              ),

              border: Border.all(
                color: Colors.white.withOpacity(0.5),
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

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Shift : $shift"),
                Text("Start : $start"),
                Text("End : $end"),

                const SizedBox(height: 4),

                Text("Status : $status"),

                const SizedBox(height: 4),

                Text("Now Serving : $nowServing"),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: status == "Running"
                        ? () => nextPatient(index)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Next"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}