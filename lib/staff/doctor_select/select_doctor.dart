import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hospital_app/common/logout_confirm.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/staff/staff_panel/staff_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_app/common/settings.dart';

class SelectDoctor extends StatefulWidget {
  const SelectDoctor({super.key});

  @override
  State<SelectDoctor> createState() => _SelectDoctorState();
}

class _SelectDoctorState extends State<SelectDoctor> {

  String hospitalName = "";
  List<Map<String, dynamic>> doctors = [];
  List<String> selectedDoctors = [];

  TextEditingController searchCtrl = TextEditingController();

  /// helper
  String formatHospitalKey(String name) {
    return name.trim().toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    loadHospital();
  }

  /// load hospital
  void loadHospital() async {
    final prefs = await SharedPreferences.getInstance();
    hospitalName = prefs.getString('currentHospital') ?? "";

    if (hospitalName.isNotEmpty) {
      loadDoctors();
      loadSelectedDoctors();
    }
  }

  /// load doctors (SharedPreferences)
  void loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();

    final hospitalKey = formatHospitalKey(hospitalName);

    /// LOCAL FIRST
    final data = prefs.getString('doctors_$hospitalKey');

    if (data != null) {
      doctors = List<Map<String, dynamic>>.from(jsonDecode(data));
    } else {
      doctors = [];
    }

    ///  FIREBASE LOAD
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('doctors')
        .get();

    if (snapshot.docs.isNotEmpty) {
      doctors = snapshot.docs.map((doc) {
        final data = doc.data();
        data['name'] ??= "No Name";
        data['dept'] ??= "General";
        return data;
      }).toList();
    }

    setState(() {});
  }

  /// load selected doctors
  void loadSelectedDoctors() async {
    final prefs = await SharedPreferences.getInstance();

    final hospitalKey = formatHospitalKey(hospitalName);

    final data = prefs.getString('selected_doctors_$hospitalKey');

    if (data != null) {
      selectedDoctors = List<String>.from(jsonDecode(data));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    final filteredDoctors = doctors.where((doc) {
      final name = (doc['name'] ?? "").toLowerCase();
      return name.contains(searchCtrl.text.toLowerCase());
    }).toList();

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title:  Text("Select Doctor",style: TextStyle(
          color: Colors.white,
        ),),

        actions: [
          IconButton(
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 16, 0),
                items: [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Image.asset('assets/icons/turn_off.png', width: 25),
                        const SizedBox(width: 10),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ).then((value) {
                if (value == 'logout') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LogoutConfirm()),
                  );
                }
              });
            },
            icon: Image.asset('assets/icons/menu.png'),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// SEARCH
            TextField(
              controller: searchCtrl,
              onChanged: (_) => setState(() {}),

              decoration: InputDecoration(
                hintText: "Search doctor",
                hintStyle: TextStyle(
                  color: AppColors.hint_text,
                  fontSize: 16,
                ),

                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),

                filled: true,
                fillColor: Colors.white.withOpacity(0.7),

                /// NORMAL BORDER (black remove)
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.inputNormal_border,
                  ),
                ),

                /// FOCUS BORDER
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.inputfocas_border,
                    width: 2,
                  ),
                ),

                /// DEFAULT BORDER OVERRIDE
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: filteredDoctors.isEmpty
                  ? const Center(child: Text("No doctor found"))
                  : ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {

                  final doctor = filteredDoctors[index];
                  final name = doctor['name'] ?? "No Name";

                  bool isSelected =
                  selectedDoctors.contains(name);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedDoctors.remove(name);
                        } else {
                          selectedDoctors.add(name);
                        }
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? AppColors.inputfocas_border
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),

                      child: Row(
                        children: [

                          /// Checkbox
                          Checkbox(
                            value: isSelected,
                            activeColor: Colors.blueAccent, // checked color
                            checkColor: Colors.white,       // tick color
                            side: BorderSide(
                              color: Colors.grey.shade400,  // border color
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (isSelected) {
                                  selectedDoctors.remove(name);
                                } else {
                                  selectedDoctors.add(name);
                                }
                              });
                            },
                          ),

                          const SizedBox(width: 10),

                          /// Doctor Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  doctor['dept'] ?? "General",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      /// BOTTOM BUTTON
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedDoctors.isEmpty
                  ? null
                  : () async {

                final prefs =
                await SharedPreferences.getInstance();

                final hospitalKey =
                formatHospitalKey(hospitalName);

                await prefs.setString(
                  'selected_doctors_$hospitalKey',
                  jsonEncode(selectedDoctors),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StaffPanel(),
                  ),
                );
              },
              child: const Text("Confirm",style: TextStyle(color: Colors.white),),
            ),
          ),
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