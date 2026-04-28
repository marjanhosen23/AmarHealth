import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hospital_app/admin/auth/admin_signup.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:hospital_app/admin/dashboard/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;
  bool hidePin = true;

  bool isValidPin(String pin) {
    final RegExp pinRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return pinRegex.hasMatch(pin);
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
                'assets/icons/admin.png',
                width: 132,
                height: 132,
              ),
            ),
          ),

          Positioned(
            top: 260,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),

                //  glass gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.card_primary.withOpacity(0.9),
                    AppColors.card_primary.withOpacity(0.8),
                  ],
                ),

                //  border
                border: Border.all(color: Colors.white.withOpacity(0.5)),

                //  shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 6,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Center(
                    child: Text('LOGIN', style: app_textstyles.sectionTitle),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF8CCBFF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFF6FA8DC),
                          width: 2,
                        ),
                      ),
                      labelText: 'Hospital Name',
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: pinController,
                    obscureText: hidePin,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Hospital PIN',
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePin ? Icons.visibility_off : Icons.visibility,
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
                  Center(
                    child: SizedBox(
                      width: 142,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
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
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Color(0xFF8CCBFF), Color(0xFF6FA8DC)],
                            ),
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Login',
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

                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account?',
                        style: app_textstyles.body,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdminSignup()),
                          );
                        },
                        child: Text(
                          ' Create',
                          style: app_textstyles.body.copyWith(
                            color: AppColors.primary_pressed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    final enteredHospital = hospitalController.text.trim();
    final enteredPin = pinController.text.trim();

    final prefs = await SharedPreferences.getInstance();

    /// multiple hospital list
    final data = prefs.getString('hospitals');

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hospital found. Please signup first')),
      );
      return;
    }

    List hospitals = jsonDecode(data);

    /// find matching hospital
    final found = hospitals.firstWhere(
      (h) =>
          h['name'].toLowerCase() == enteredHospital.toLowerCase() &&
          h['pin'] == enteredPin,
      orElse: () => null,
    );

    if (found == null) {
      final hospitalKey = enteredHospital.trim().toLowerCase();

      final snapshot = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null && data['pin'] == enteredPin) {
          /// save locally (same as before)
          await prefs.setString('currentHospital', data['name']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(hospitalName: data['name']),
            ),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid login credentials')),
      );
      return;
    }

    ///  save current hospital
    await prefs.setString('currentHospital', found['name']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboard(hospitalName: found['name']),
      ),
    );
  }

  @override
  void dispose() {
    hospitalController.dispose();
    pinController.dispose();
    super.dispose();
  }
}
