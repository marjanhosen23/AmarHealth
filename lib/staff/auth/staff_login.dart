import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/staff/doctor_select/select_doctor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffLogin extends StatefulWidget {
  StaffLogin({super.key});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool isLoading = false;
  bool hidePin = true;

  bool isValidPin(String pin) {
    final RegExp pinRegex = RegExp(r'^\d{4}$');
    return pinRegex.hasMatch(pin);
  }

  ///  IMPORTANT: same format everywhere
  String formatHospitalKey(String name) {
    return name.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 100,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icons/staff.png',
                width: 132,
                height: 132,
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card_primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'LOGIN',
                      style: app_textstyles.sectionTitle,
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      labelText: 'Hospital Name',
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),

                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),

                      /// NORMAL BORDER
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

                      /// REMOVE DEFAULT BLACK
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),

                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),

                      /// NORMAL BORDER
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

                      /// REMOVE DEFAULT BLACK
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: pinController,
                    obscureText: hidePin,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],

                    decoration: InputDecoration(
                      labelText: 'Staff PIN',
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
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

                      ///DEFAULT BORDER OVERRIDE
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePin ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePin = !hidePin;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isLoading ? null : _login,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF8BCAFE),
                                Color(0xFF70AADE),
                              ],
                            ),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    final hospital = hospitalController.text.trim();
    final name = nameController.text.trim();
    final pin = pinController.text.trim();

    if (hospital.isEmpty || name.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সব ফিল্ড পূরণ করতে হবে')),
      );
      return;
    }

    if (!isValidPin(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN অবশ্যই ৪ ডিজিট হতে হবে')),
      );
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    final hospitalKey = formatHospitalKey(hospital);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .collection('staffs')
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital not found')),
        );
        return;
      }

      bool isValid = snapshot.docs.any((doc) {
        final staff = doc.data();


        return staff['name'].toString().trim().toLowerCase() ==
            name.toLowerCase() &&
            staff['pin'].toString() == pin &&
            (staff['status'] ?? 'active')
                .toString()
                .toLowerCase() ==
                'active';
      });

      setState(() => isLoading = false);

      if (isValid) {
        ///use hospitalKey (not original)
        await prefs.setString('currentHospital', hospitalKey);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectDoctor()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Name / PIN')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  @override
  void dispose() {
    nameController.dispose();
    pinController.dispose();
    hospitalController.dispose();
    super.dispose();
  }
}