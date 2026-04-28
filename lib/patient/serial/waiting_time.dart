import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitingTime extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String hospital;
  final String serial;

  const WaitingTime({
    super.key,
    required this.doctor,
    required this.hospital,
    required this.serial,
  });

  @override
  State<WaitingTime> createState() => _WaitingTimeState();
}

class _WaitingTimeState extends State<WaitingTime> {

  int nowServing = 0;
  int beforeYou = 0;
  int waitingTime = 0;
  int yourSerial = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadData();

    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// convert time → minutes
  int parseToMinutes(String time) {
    final parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// main logic
  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final hospitalKey = widget.hospital.trim().toLowerCase();

    final data = prefs.getString('today_settings_$hospitalKey');

    int current = 0;
    int avgTime = 5;
    int delay = 0;

    /// LOCAL (same as before)
    if (data != null) {
      List list = jsonDecode(data);

      var found = list.where((d) =>
      d['name'] == widget.doctor['name'] &&
          d['hospital'] == widget.hospital
      ).toList();

      if (found.isNotEmpty) {
        var doc = found.first;

        current = doc['nowServing'] ?? 0;

        String timeStr = doc['time'] ?? "5";
        avgTime = int.tryParse(
          timeStr.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ?? 5;
      }
    }

    /// FIREBASE LOAD
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('today_settings')
        .doc(widget.doctor['name'])
        .get();

    if (snapshot.exists) {
      final doc = snapshot.data();

      current = doc?['nowServing'] ?? current;

      String timeStr = doc?['time'] ?? "5";
      avgTime = int.tryParse(
        timeStr.replaceAll(RegExp(r'[^0-9]'), ''),
      ) ?? avgTime;

      if (doc?['startTime'] != null) {
        int start = parseToMinutes(doc!['startTime']);
        TimeOfDay now = TimeOfDay.now();
        int currentTime = now.hour * 60 + now.minute;

        if (currentTime < start) {
          delay = start - currentTime;
        }
      }
    }

    /// CALCULATION SAME
    yourSerial = int.tryParse(widget.serial) ?? 0;
    beforeYou = yourSerial - current;
    if (beforeYou < 0) beforeYou = 0;

    waitingTime = (beforeYou * avgTime) + delay;

    setState(() {
      nowServing = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset('assets/icons/arrow.png', color: Colors.white),
        ),
        title: Text(
          "অপেক্ষার সময়",
          style: app_textstyles.appBarTitle.copyWith(
            color: AppColors.inputColor,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            // glass gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.card_primary.withOpacity(0.8),
                AppColors.card_primary.withOpacity(0.2),
              ],
            ),

            //  border highlight
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),

            //  soft shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
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
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "ডাক্তার : ${widget.doctor['name']}",
                style: app_textstyles.body.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text("বিভাগ : ${widget.doctor['dept']}"),

              const SizedBox(height: 10),

              Text("এখন চলছে : $nowServing"),

              const SizedBox(height: 10),

              Text("আপনার সিরিয়াল : $yourSerial"),

              const SizedBox(height: 10),

              Text("আপনার আগে : $beforeYou"),

              const SizedBox(height: 10),

              Text(
                "আনুমানিক অপেক্ষা : $waitingTime মিনিট",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

        ),
      ),
    );
  }
}