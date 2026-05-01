import 'package:flutter/material.dart';
import 'package:hospital_app/admin/auth/admin_login.dart';
import 'package:hospital_app/admin/doctor_management/doctor_management.dart';
import 'package:hospital_app/admin/staff_management/staff_Management.dart';
import 'package:hospital_app/admin/today_setting/todays_settings.dart';
import 'package:hospital_app/common/logout_confirm.dart';
import 'package:hospital_app/common/settings.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';

class AdminDashboard extends StatefulWidget {
  final String hospitalName;

  const AdminDashboard({super.key, this.hospitalName = ''});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectManage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,

        title: Text(
          'Dashboard',
          style: app_textstyles.appBarTitle.copyWith(
            color: AppColors.inputColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 16, 0),
                items: [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/settings.png',
                          width: 25,
                          height: 25,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Settings',
                          style: app_textstyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/turn_off.png',
                          width: 25,
                          height: 25,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          'Logout',
                          style: app_textstyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                color: AppColors.card_primary,
              ).then((value) {
                if (value == 'logout') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LogoutConfirm()),
                  );
                }
                else if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Settings(),
                    ),
                  );
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/icons/menu.png',
                width: 45,
                height: 45,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            // Hospital header (outside card)
            Row(
              children: [
                SizedBox(width: 24),
                Image.asset('assets/icons/hospital.png', width: 32),
                const SizedBox(width: 10),
                Text(widget.hospitalName, style: app_textstyles.sectionTitle),
              ],
            ),

            const SizedBox(height: 50),

            // Big card starts here
            Container(
              width: double.infinity,
              height: 593,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card_primary,
                borderRadius: BorderRadius.circular(34),
              ),

              child: Column(
                children: [
                  ManageCard(
                    'Doctor Management',
                    'assets/icons/sthetoscope.png',
                  ),
                  SizedBox(height: 20),
                  ManageCard(
                    'Staff Management',
                    'assets/icons/staff_dashboard.png',
                  ),
                  SizedBox(height: 20),
                  ManageCard("Today's Setting", 'assets/icons/gears.png'),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget ManageCard(String Title, String imagePath) {
    bool isSelected = selectManage == Title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectManage = Title;
        });
        if (Title == 'Doctor Management') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DoctorManagement()),
          );
        }
        if (Title == 'Staff Management') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StaffManagement()),
          );
        }
        if (Title == "Today's Setting") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TodaysSettings()),
          );
        }
      },
      child: Container(
        width: 321,
        height: 112,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          // glass gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.6),
              Colors.white.withOpacity(0.2),
            ],
          ),

          // border
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.5),
            width: 2,
          ),

          // glass shadow
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
        child: Row(
          children: [
            Image.asset(imagePath, width: 40, height: 40),
            SizedBox(width: 10),
            Text(
              Title,
              style: app_textstyles.appBarTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
