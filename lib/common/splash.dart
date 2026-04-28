import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'role_select.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleSelect()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// background gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.splashTop,
              AppColors.splashMiddle,
              AppColors.splashBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Stack(
          children: [

            /// CENTER LOGO (Heart)
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/splash/Logo1.png',
                  width: 150,
                ),
              ),
            ),

            /// SHIELD TOP LEFT
            Positioned(
              top: 180,
              left: 80,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/splash/shield.png',
                  width: 40,
                ),
              ),
            ),

            /// SMALL STAR EFFECT
            Positioned(
              top: 200,
              left: 110,
              child: Icon(Icons.star,
                  color: Colors.white.withOpacity(0.4), size: 14),
            ),

            /// MEDICINE IMAGE (BOTTOM LEFT)
            Positioned(
              bottom: 120,
              left: 40,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/splash/medicine.png',
                  width: 140,
                ),
              ),
            ),

            /// SPARKLES RIGHT SIDE
            Positioned(
              bottom: 200,
              right: 50,
              child: Column(
                children: [
                  Icon(Icons.star,
                      color: Colors.white.withOpacity(0.4), size: 10),
                  SizedBox(height: 10),
                  Icon(Icons.star,
                      color: Colors.white.withOpacity(0.3), size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}