import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hospital_app/admin/auth/admin_signup.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:hospital_app/admin/dashboard/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hospital_app/admin/auth/forgetpassword.dart';


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
                    Theme.of(context).cardColor.withOpacity(0.9),
                    Theme.of(context).cardColor.withOpacity(0.8),
                  ],
                ),

                //  border
                border: Border.all(color: Colors.white.withOpacity(0.5)),

                //  shadow
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Theme.of(context).highlightColor.withOpacity(0.3),
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
                    child: Text('LOGIN', style: app_textstyles.sectionTitle.copyWith(
                      color: AppColors.primary,
                    )),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
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

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.inputNormal_border,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.inputfocas_border,
                          width: 2,
                        ),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isLoading ? null : _login,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                  Theme.of(context).colorScheme.primary,
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
                  ),

                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account?',
                        style: app_textstyles.body.copyWith(
                          color: AppColors.primary
                        ),
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

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Forgetpassword(),
                          ),
                        );

                      },

                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

    String email = "${enteredHospital.toLowerCase().replaceAll(' ', '')}@app.com";
    String password = enteredPin;

    if (enteredHospital.isEmpty || enteredPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    final hospitalKey = enteredHospital.toLowerCase();

    try {
      /// Firestore check
      final snapshot = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .get(const GetOptions(source: Source.server));

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital not found')),
        );
        setState(() => isLoading = false);
        return;
      }

      final data = snapshot.data();

      ///Soft delete
      if (data?['deleted'] == true) {
        final Timestamp? ts = data?['deleteTime'];

        if (ts != null) {
          final deleteTime = ts.toDate();
          final now = DateTime.now();
          final diff = now.difference(deleteTime);

          if (diff.inDays > 30) {
            await FirebaseFirestore.instance
                .collection('hospitals')
                .doc(hospitalKey)
                .delete();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account permanently deleted')),
            );

            setState(() => isLoading = false);
            return;
          }
        }

        await FirebaseFirestore.instance
            .collection('hospitals')
            .doc(hospitalKey)
            .update({
          'deleted': false,
          'deleteTime': null,
        });
      }

      ///PIN check (UNCHANGED)
      if (data == null || data['pin'] != enteredPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN')),
        );
        setState(() => isLoading = false);
        return;
      }

      ///FirebaseAuth login (ADDED)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// save hospital (unchanged)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hospitalKey', hospitalKey);
      await prefs.setString('hospitalName', data?['name']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboard(
            hospitalName: data['name'],
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection')),
      );
      return;
    }


    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    hospitalController.dispose();
    pinController.dispose();
    super.dispose();
  }
}
