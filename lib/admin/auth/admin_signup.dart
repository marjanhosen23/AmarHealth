import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSignup extends StatefulWidget {
  const AdminSignup({super.key});

  @override
  State<AdminSignup> createState() => _AdminSignupState();
}

class _AdminSignupState extends State<AdminSignup> {
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  bool hidePin = true;
  bool isLoading = false;
  bool hideConfirmPin = true;

  bool isValidPin(String pin) {
    final RegExp pinRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return pinRegex.hasMatch(pin);
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidMobile(String mobile) {
    final RegExp mobileRegex = RegExp(r'^01[3-9]\d{8}$');
    return mobileRegex.hasMatch(mobile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),

              // glass effect
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.card_primary.withOpacity(0.7),
                  AppColors.card_primary.withOpacity(0.5),
                ],
              ),

              border: Border.all(color: Colors.white.withOpacity(0.5)),

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
              children: [
                Text(
                  "Signup",
                  style: app_textstyles.sectionTitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.0),

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
                SizedBox(height: 16.0),

                TextField(
                  controller: emailController,
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
                    labelText: 'Email',

                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: mobileController,
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

                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: pinController,
                  obscureText: hidePin,
                  keyboardType: TextInputType.text,
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
                SizedBox(height: 16),
                TextField(
                  controller: confirmPinController,
                  obscureText: hideConfirmPin,
                  keyboardType: TextInputType.text,
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

                    labelText: 'Confirm PIN',
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
                          hideConfirmPin = !hideConfirmPin;
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
                      onPressed: isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),

                          gradient: LinearGradient(
                            colors: [Color(0xFF8CCBFF), Color(0xFF6FA8DC)],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
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
                            'Sign up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signup() async {
    final hospitalName = hospitalController.text.trim();
    final emailInput = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    // 🔥 generated email (login এর সাথে match করবে)
    final email = "${hospitalName.toLowerCase().replaceAll(' ', '')}@app.com";

    if (hospitalName.isEmpty ||
        emailInput.isEmpty ||
        mobile.isEmpty ||
        pin.isEmpty ||
        confirmPin.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    if (!isValidEmail(emailInput)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid email format')));
      return;
    }

    if (!isValidMobile(mobile)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid mobile number')));
      return;
    }

    if (!isValidPin(pin)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Weak PIN')));
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('PIN not matched')));
      return;
    }

    setState(() => isLoading = true);

    final hospitalKey = hospitalName.toLowerCase();

    try {
      /// 🔥 1. duplicate check (unchanged)
      final doc = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .get();

      if (doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital already exists')),
        );
        setState(() => isLoading = false);
        return;
      }

      /// 🔥 2. FirebaseAuth account create (NEW)
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pin,
      );

      /// 🔥 3. Firestore save (unchanged)
      await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .set({
        "name": hospitalName,
        "email": emailInput,
        "mobile": mobile,
        "pin": pin,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signup successful')));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => isLoading = false);
  }
}
