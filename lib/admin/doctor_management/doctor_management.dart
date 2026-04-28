import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hospital_app/admin/doctor_management/add_doctor.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorManagement extends StatefulWidget {
  const DoctorManagement({super.key});

  @override
  State<DoctorManagement> createState() => _DoctorManagementState();
}

class _DoctorManagementState extends State<DoctorManagement> {

  List<Map<String, dynamic>> doctors = [];
  String hospitalId = "default";

  @override
  void initState() {
    super.initState();
    loadHospital();
  }

  void loadHospital() async {
    final prefs = await SharedPreferences.getInstance();
    hospitalId = prefs.getString('currentHospital') ?? "default";
    loadDoctors();
  }

  void loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();

    final hospitalKey = hospitalId.trim().toLowerCase();

    final data = prefs.getString('doctors_$hospitalKey');

    if (data != null) {
      setState(() {
        doctors = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void saveDoctors() async {
    final prefs = await SharedPreferences.getInstance();

    final hospitalKey = hospitalId.trim().toLowerCase();

    prefs.setString(
      'doctors_$hospitalKey',
      jsonEncode(doctors),
    );
    for (var doc in doctors) {
      await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .collection('doctors')
          .doc(doc['name'])
          .set(doc);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Doctor Management"),
      ),

      body: Column(
        children: [

          /// ADD BUTTON (same style)
          GestureDetector(
            onTap: () async {
              final newDoctor = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDoctor()),
              );

              if (newDoctor != null) {
                setState(() {
                  doctors.add(newDoctor);
                });
                saveDoctors();
              }
            },

            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 220,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),

                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8CCBFF),
                      Color(0xFF6FA8DC),
                    ],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/plus.png",width: 18,),
                    const SizedBox(width: 8),
                    Text("Add Doctor",
                        style: app_textstyles.appBarTitle),
                  ],
                ),
              ),
            ),
          ),

          /// LIST
          Expanded(
            child: doctors.isEmpty
                ? const Center(child: Text("No doctor found"))
                : ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {

                return DoctorCard(
                  name: doctors[index]['name'] ?? '',
                  dept: doctors[index]['dept'] ?? '',
                  time: doctors[index]['time'] ?? '',

                  onEdit: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddDoctor(
                          name: doctors[index]['name'],
                          dept: doctors[index]['dept'],
                          time: doctors[index]['time'],
                        ),
                      ),
                    );

                    if (updated != null) {
                      setState(() {
                        doctors[index] = updated;
                      });
                      saveDoctors();
                    }
                  },

                  onDelete: () async {
                    final hospitalKey = hospitalId.trim().toLowerCase();
                    final doctorName = doctors[index]['name'];

                    try {
                      /// delete from doctors collection
                      await FirebaseFirestore.instance
                          .collection('hospitals')
                          .doc(hospitalKey)
                          .collection('doctors')
                          .doc(doctorName)
                          .delete();

                      /// delete from today_settings
                      await FirebaseFirestore.instance
                          .collection('hospitals')
                          .doc(hospitalKey)
                          .collection('today_settings')
                          .doc(doctorName)
                          .delete();

                      ///remove from UI
                      setState(() {
                        doctors.removeAt(index);
                      });

                      /// update local (optional)
                      saveDoctors();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Doctor deleted successfully")),
                      );

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Delete failed: $e")),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= CARD =================

class DoctorCard extends StatelessWidget {
  final String name;
  final String dept;
  final dynamic time;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoctorCard({
    super.key,
    required this.name,
    required this.dept,
    required this.time,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 18, left: 20, right: 20),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        //  glass gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card_primary.withOpacity(0.5),
            AppColors.card_primary.withOpacity(0.2),
          ],
        ),

        //  border
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ),

        //  shadow
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

          /// NAME
          Text(
            name,
            style: app_textstyles.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          /// DEPT
          Text("Department: $dept"),

          const SizedBox(height: 5),

          /// TIME
          Text("Time: $time min"),

          const SizedBox(height: 10),

          /// BUTTONS
          Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF8CCBFF),
                          Color(0xFF6FA8DC),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Edit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent,
                          Colors.red,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}