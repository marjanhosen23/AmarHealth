import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hospital_app/patient/doctor/doctor_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalList extends StatefulWidget {
  const HospitalList({super.key});

  @override
  State<HospitalList> createState() => _HospitalListState();
}

class _HospitalListState extends State<HospitalList> {

  List<String> hospitals = [];
  List<String> filteredHospitals = [];

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadHospitals();
  }

  /// load hospital from local storage
  void loadHospitals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .get();

    hospitals = snapshot.docs.where((doc) {
      final data = doc.data();
      return (data['deleted'] ?? false) != true;
    }).map((doc) {
      return (doc.data()['name'] ?? '').toString();
    }).toList();

    filteredHospitals = hospitals;
    setState(() {});
  }
  /// search filter
  void filterSearch(String value) {
    setState(() {
      filteredHospitals = hospitals.where((h) {
        return h.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "হাসপাতাল নির্বাচন",
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

            /// search
            TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "হাসপাতাল খুঁজুন",
                hintStyle: TextStyle(
                  color: AppColors.hint_text

                ),
                prefixIcon: const Icon(Icons.search),
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

            Text(
              "হাসপাতালের তালিকা",
              style: app_textstyles.body.copyWith(fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),

            const SizedBox(height: 10),

            /// list
            Expanded(
              child: filteredHospitals.isEmpty
                  ? const Center(child: Text("No hospital found"))
                  : ListView.builder(
                itemCount: filteredHospitals.length,
                itemBuilder: (context, index) {

                  final hospital = filteredHospitals[index];

                  return GestureDetector(
                    onTap: () async {

                      final prefs = await SharedPreferences.getInstance();

                      /// FIXED KEY (IMPORTANT)
                      await prefs.setString(
                        'currentHospital',
                        hospital.trim().toLowerCase(),
                      );

                      /// go to doctor list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DoctorList(),
                        ),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: AppColors.card_primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Text(
                        hospital,
                        style: app_textstyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}