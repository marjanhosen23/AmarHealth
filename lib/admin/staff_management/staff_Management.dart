import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hospital_app/admin/staff_management/add_staff.dart';
import 'package:hospital_app/admin/staff_management/change_pin.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});

  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  List<Map<String, dynamic>> staffs = [];
  String hospitalId = "default";

  @override
  void initState() {
    super.initState();
    loadHospital();
  }

  // Get current hospital
  void loadHospital() async {
    final prefs = await SharedPreferences.getInstance();
    hospitalId = prefs.getString('currentHospital') ?? "default";
    loadStaffs();
  }

  //  Load staff per hospital
  void loadStaffs() async {
    final hospitalKey = hospitalId.trim().toLowerCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalKey)
        .collection('staffs')
        .get();

    final data = snapshot.docs.map((doc) {
      final d = Map<String, dynamic>.from(doc.data());
      d['id'] = doc.id;
      return d;
    }).toList();

    setState(() {
      staffs = data;
    });
  }

  // Save staff per hospital

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const Text("Staff Management")],
        ),
      ),
      body: Column(
        children: [
          /// Add Staff Button
          GestureDetector(
            onTap: () async {
              final newStaff = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddStaff()),
              );

              if (newStaff != null) {
                final hospitalKey = hospitalId.trim().toLowerCase();

                final ref = await FirebaseFirestore.instance
                    .collection('hospitals')
                    .doc(hospitalKey)
                    .collection('staffs')
                    .add(newStaff);

                newStaff['id'] = ref.id;

                setState(() {
                  staffs.add(newStaff);
                });
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
                    colors: [Color(0xFF8BCAFE), Color(0xFF70AADE)],
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
                    Image.asset("assets/icons/plus.png", width: 18),
                    const SizedBox(width: 8),
                    Text('Add New Staff', style: app_textstyles.appBarTitle),
                  ],
                ),
              ),
            ),
          ),

          ///  Staff List
          Expanded(
            child: staffs.isEmpty
                ? const Center(child: Text("No staff found"))
                : ListView.builder(
                    itemCount: staffs.length,
                    itemBuilder: (context, index) {
                      return StaffCard(
                        name: staffs[index]['name'] ?? '',
                        role: staffs[index]['role'] ?? '',
                        pin: staffs[index]['pin'] ?? '',
                        status: staffs[index]['status'] ?? 'Active',

                        onRemove: () async {
                          final hospitalKey = hospitalId.trim().toLowerCase();
                          final docId = staffs[index]['id'];

                          await FirebaseFirestore.instance
                              .collection('hospitals')
                              .doc(hospitalKey)
                              .collection('staffs')
                              .doc(docId)
                              .delete();

                          setState(() {
                            staffs.removeAt(index);
                          });
                        },

                        onChangePin: () async {
                          final newPin = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChangePin(oldPin: staffs[index]['pin']),
                            ),
                          );

                          if (newPin != null) {
                            final hospitalKey = hospitalId.trim().toLowerCase();
                            final docId = staffs[index]['id'];

                            await FirebaseFirestore.instance
                                .collection('hospitals')
                                .doc(hospitalKey)
                                .collection('staffs')
                                .doc(docId)
                                .update({'pin': newPin});

                            setState(() {
                              staffs[index]['pin'] = newPin;
                            });
                          }
                        },

                        onToggleStatus: () async {
                          final hospitalKey = hospitalId.trim().toLowerCase();
                          final docId = staffs[index]['id'];

                          final newStatus = staffs[index]['status'] == 'Active'
                              ? 'Inactive'
                              : 'Active';

                          await FirebaseFirestore.instance
                              .collection('hospitals')
                              .doc(hospitalKey)
                              .collection('staffs')
                              .doc(docId)
                              .update({'status': newStatus});

                          setState(() {
                            staffs[index]['status'] = newStatus;
                          });
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

class StaffCard extends StatefulWidget {
  final String name;
  final String role;
  final String pin;
  final String status;
  final VoidCallback onRemove;
  final VoidCallback onChangePin;
  final VoidCallback onToggleStatus;

  const StaffCard({
    super.key,
    required this.name,
    required this.role,
    required this.pin,
    required this.status,
    required this.onRemove,
    required this.onChangePin,
    required this.onToggleStatus,
  });

  @override
  State<StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<StaffCard> {
  bool showPin = false;

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
            AppColors.card_primary.withOpacity(0.6),
            AppColors.card_primary.withOpacity(0.2),
          ],
        ),

        //  border
        border: Border.all(color: Colors.white.withOpacity(0.5)),

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
          Text(
            widget.name,
            style: app_textstyles.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text('Role: ${widget.role}'),

          const SizedBox(height: 5),

          Row(
            children: [
              Text('PIN: ${showPin ? widget.pin : "****"}'),
              IconButton(
                icon: Icon(showPin ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    showPin = !showPin;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text('Status: ${widget.status}'),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onChangePin,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Color(0xFF8BCAFE), Color(0xFF70AADE)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Change Pin",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onToggleStatus,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),

                      gradient: LinearGradient(
                        colors: widget.status == "Active"
                            ? [Colors.orangeAccent, Colors.orange]
                            : [Colors.green, Colors.greenAccent],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.status == "Active" ? "Deactivate" : "Activate",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onRemove,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),

                      // red gradient
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.red],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Remove",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
