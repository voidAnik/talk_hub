import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:talk_hub/config/theme/colors.dart';
import 'package:talk_hub/core/constants/assets.dart';
import 'package:talk_hub/core/extensions/context_extension.dart';
import 'package:talk_hub/features/authentication/presentation/screens/login_screen.dart';
import 'package:talk_hub/features/home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        context.go(HomeScreen.path);
      } else {
        context.go(LoginScreen.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(Assets.assetsChat, height: context.height * 0.3),
            const SizedBox(height: 32),
            Text(
              'Talk Hub',
              style: GoogleFonts.aldrich(
                  fontSize: context.width * 0.05, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
