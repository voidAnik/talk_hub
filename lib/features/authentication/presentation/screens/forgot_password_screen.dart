import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_hub/features/authentication/presentation/widgets/decorations.dart';

class ForgotPasswordAuthScreen extends ForgotPasswordScreen {
  static const String path = '/forgot_password';
  ForgotPasswordAuthScreen({super.key, required String email})
      : super(
          email: email,
          headerMaxExtent: 200,
          headerBuilder: headerIcon(Icons.lock),
          sideBuilder: sideIcon(Icons.lock),
        );
}
