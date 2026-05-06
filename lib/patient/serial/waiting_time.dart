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

  String statusMessage = "";

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

  /// SAFE parse function (fix crash)
  int parseToMinutes(String? time) {
    if (time == null || time.isEmpty || !time.contains(":")) {
      return 0;
    }

    final parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final hospitalKey = widget.hospital.trim().toLowerCase();

    final data = prefs.getString('today_settings_$hospitalKey');

    int current = 0;
    int avgTime = 5;
    int delay = 0;

    /// LOCAL
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

    /// FIREBASE
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('today_settings')
        .doc(widget.doctor['name'])
        .get(const GetOptions(source: Source.server));

    if (snapshot.exists) {
      final doc = snapshot.data();

      int start = parseToMinutes(doc?['startTime']);
      int end = parseToMinutes(doc?['endTime']);

      TimeOfDay now = TimeOfDay.now();
      int currentTime = now.hour * 60 + now.minute;

      ///STATUS LOGIC (fixed)
      if (currentTime < start && start != 0) {
        statusMessage = "ডাক্তার এখনও আসেনি";
      } else if (currentTime > end && end != 0) {
        statusMessage = "এই শিফট শেষ হয়েছে";
        waitingTime = 0;
      } else {
        statusMessage = "";
      }

      current = doc?['nowServing'] ?? current;
      avgTime = doc?['time'] ?? avgTime;

      if (start != 0 && currentTime < start) {
        delay = start - currentTime;
      }
    }

    /// CALCULATION
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
    final hospitalKey = widget.hospital.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
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

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospitals')
            .doc(hospitalKey)
            .collection('today_settings')
            .doc(widget.doctor['name'])
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          final doc = snapshot.data!.data() as Map<String, dynamic>;

          int current = doc['nowServing'] ?? 0;
          int avgTime = doc['time'] ?? 5;

          int start = parseToMinutes(doc['startTime']);
          int end = parseToMinutes(doc['endTime']);

          TimeOfDay now = TimeOfDay.now();
          int currentTime = now.hour * 60 + now.minute;

          int delay = 0;

          /// STATUS
          if (currentTime < start && start != 0) {
            statusMessage = "ডাক্তার এখনও আসেনি";
          } else if (currentTime > end && end != 0) {
            statusMessage = "এই শিফট শেষ হয়েছে";
            waitingTime = 0;
          } else {
            statusMessage = "";
          }

          if (start != 0 && currentTime < start) {
            delay = start - currentTime;
          }

          /// CALCULATION
          yourSerial = int.tryParse(widget.serial) ?? 0;
          beforeYou = yourSerial - current;
          if (beforeYou < 0) beforeYou = 0;

          waitingTime = (beforeYou * avgTime) + delay;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.card_primary.withOpacity(0.8),
                    AppColors.card_primary.withOpacity(0.2),
                  ],
                ),
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

                  if (statusMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 10),
                      child: Text(
                        statusMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  Text("বিভাগ : ${widget.doctor['dept']}"),
                  const SizedBox(height: 10),

                  Text("এখন চলছে : $current"),
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
          );
        },
      ),
    );
  }
}