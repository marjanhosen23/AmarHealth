import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hospital_app/patient/serial/serial_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({super.key});

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];

  String hospitalName = "";

  TextEditingController searchCtrl = TextEditingController();


  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  void loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();

    hospitalName = prefs.getString('currentHospital') ?? "";

    final hospitalKey = hospitalName.trim().toLowerCase();

    /// LOCAL LOAD
    final todayData =
        prefs.getString('today_settings_$hospitalKey') ??
            prefs.getString('doctors_$hospitalKey');

    if (todayData != null) {
      List<Map<String, dynamic>> allDoctors =
      List<Map<String, dynamic>>.from(jsonDecode(todayData));

      doctors = allDoctors.where((doc) {
        return doc['active'] == true;
      }).toList();

      filteredDoctors = doctors;
    }

    ///FIREBASE LOAD (NEW)

    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('today_settings')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final firebaseDoctors =
      snapshot.docs.map((doc) => doc.data()).toList();

      doctors = firebaseDoctors.where((doc) {
        return (doc['active'] ?? false) == true;
      }).toList();

      filteredDoctors = doctors;
    }

    setState(() {});
  }
  void filterSearch(String value) {
    setState(() {
      filteredDoctors = doctors.where((doc) {
        final name = (doc['name'] ?? "").toLowerCase();
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "আজ যেসব ডাক্তার বসবেন",
          style: app_textstyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Hospital Name
            Row(
              children: [
                Image.asset('assets/icons/hospital.png', width: 32),
                const SizedBox(width: 8),
                Text(
                  hospitalName,
                  style: app_textstyles.sectionTitle.copyWith(fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Search
            TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "ডাক্তার খুঁজুন",
                hintStyle: TextStyle(
                    color: AppColors.hint_text,),
                prefixIcon:  Icon(Icons.search,color: AppColors.primary,),
                filled: true,
                fillColor: AppColors.card_primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: filterSearch,
            ),

            const SizedBox(height: 20),

            /// Doctor List
            Expanded(
              child: filteredDoctors.isEmpty
                  ? const Center(child: Text("No doctor found"))
                  : ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SerialInput(
                            doctor: doctor,
                            hospital: hospitalName, // fixed
                          ),
                        ),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),

                        //  glass gradient
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.card_primary.withOpacity(0.6),
                            AppColors.card_primary.withOpacity(0.2),
                          ],
                        ),

                        // border
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),

                        // shadow
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

                          /// Name
                          Text(
                            doctor['name'] ?? '',
                            style: app_textstyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// Department
                          Text("Department: ${doctor['dept'] ?? ''}"),

                          const SizedBox(height: 4),

                          /// Time
                          Text(
                            "Time: ${formatTime(doctor['startTime'])} - ${formatTime(doctor['endTime'])}",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(String? time) {
    if (time == null) return "--";

    final parts = time.split(":");

    final dt = DateTime(
      0,
      0,
      0,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return DateFormat('hh:mm a').format(dt);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}