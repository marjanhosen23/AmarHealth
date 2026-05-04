import 'package:flutter/material.dart';
import 'package:hospital_app/admin/auth/admin_login.dart';
import 'package:hospital_app/patient/hospital/hospital_list.dart';
import 'package:hospital_app/staff/auth/staff_login.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';

class RoleSelect extends StatefulWidget {
   RoleSelect({super.key});

  @override
  State<RoleSelect> createState() => _RoleSelectState();
}

class _RoleSelectState extends State<RoleSelect> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 10,
                offset: Offset(0, 6),
              )
            ]

        ),
        child: Stack(
          children: [
            Positioned(
              left: 80,
              top: 70,
              child: Image.asset(
                'assets/images/select_page_image.png',
                width: 230,
                height: 319,
              ),
            ),
            Positioned(
              top: 320,
              left: 13,
              right: 13,
              child: Container(
                padding:  EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).cardColor.withOpacity(1.0),
                      AppColors.card_primary.withOpacity(1.0),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.25),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                    BoxShadow(
                      color:Theme.of(context).cardColor.withOpacity(0.6),
                      blurRadius: 6,
                      offset: Offset(-2, -2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      "আপনি কে?",
                      style: app_textstyles.sectionTitle,
                    ),
                     SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            roleCard('User', 'assets/icons/woman.png'),
                             SizedBox(height: 20),
                            roleCard('Admin', 'assets/icons/admin.png'),
                          ],
                        ),
                         SizedBox(width: 20),
                        roleCard('Staff', 'assets/icons/staff.png'),
                      ],
                    ),
                     SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          if (selectedRole.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('আগে একটি Role নির্বাচন করুন')),
                            );
                            return;
                          }

                          if (selectedRole == 'User') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => HospitalList()));
                          } else if (selectedRole == 'Staff') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => StaffLogin()));
                          } else if (selectedRole == 'Admin') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminLogin()));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),

                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.8),
                                AppColors.primary.withOpacity(0.6),
                              ],
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: app_textstyles.button.copyWith(color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                'assets/icons/right-arrow.png',
                                width: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget roleCard(String title, String imagePath) {
    bool isSelected = selectedRole == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = title;
        });
      },
      child: Container(
        width: 140,
        padding:  EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),

          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor.withOpacity(0.6),
              Theme.of(context).cardColor.withOpacity(0.2)
            ],
          ),

          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.5),
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.25),
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
            Image.asset(imagePath, width: 72, height: 72), SizedBox(height: 8),
            Text(title, style: app_textstyles.cardTitle),
          ],
        ),
      ),
    );
  }
}