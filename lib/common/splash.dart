import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'role_select.dart';
import 'dart:math';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 5), () {
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

        /// Background Gradient
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
            ///CENTER LOGO + GLASS CIRCLE
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// MAIN CIRCLE
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.6), // strong light
                          Colors.white.withOpacity(0.1), // middle soft
                          Colors.transparent, // fade out
                        ],
                        stops: [0.0, 0.5, 0.9],
                      ),
                      border: Border.all(
                        color: AppColors.splashMiddle.withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                  ),

                  /// LOGO
                  ScaleTransition(
                    scale: _scale,
                    child: Image.asset('assets/splash/logo3.png', width: 150),
                  ),
                ],
              ),
            ),

            ///  SHIELD
            Positioned(
              top: 300,
              left: 80,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset('assets/splash/shield.png', width: 50),
              ),
            ),

            Positioned(
              top: 315,
              left: 95,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/icons/plus.png', width: 20),
              ),
            ),

            Positioned(
              top: 300,
              left: 80,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset('assets/splash/shield.png', width: 50),
              ),
            ),

            /// MEDICINE (BOTTOM LEFT)
            Positioned(
              bottom: 250,
              left: 40,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset('assets/splash/medicine.png', width: 120),
              ),
            ),

            ///Stars
            Positioned(
              bottom: 270,
              left: 160,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 10),
              ),
            ),

            Positioned(
              top: 260,
              left: 150,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 25),
              ),
            ),

            Positioned(
              top: 300,
              right: 120,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 25),
              ),
            ),

            Positioned(
              bottom: 280,
              right: 150,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 30),
              ),
            ),

            Positioned(
              bottom: 300,
              right: 100,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 20),
              ),
            ),

            Positioned(
              bottom: 380,
              right: 100,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 20),
              ),
            ),
            Positioned(
              bottom: 460,
              right: 60,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 20),
              ),
            ),

            Positioned(
              bottom: 260,
              right: 60,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 15),
              ),
            ),

            Positioned(
              bottom: 260,
              left: 60,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 15),
              ),
            ),

            Positioned(
              bottom: 300,
              left: 40,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 25),
              ),
            ),

            Positioned(
              bottom: 370,
              left: 60,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/splash/sparkler.png', width: 25),
              ),
            ),
            Positioned(
              bottom: 440,
              left: 80,
              child: Opacity(
                opacity: 0.3,
                child: Image.asset('assets/splash/sparkler.png', width: 25),
              ),
            ),

            ///Injection
            Positioned(
              top: 320,
              right: 80,
              child: Opacity(
                opacity: 0.3,
                child: Image.asset('assets/splash/injection.png', width: 50),
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
