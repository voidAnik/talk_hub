import 'dart:developer';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_hub/core/injection/injection_container.dart';
import 'package:talk_hub/features/authentication/domain/use_cases/save_user.dart';
import 'package:talk_hub/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:talk_hub/features/authentication/presentation/widgets/decorations.dart';
import 'package:talk_hub/features/home/presentation/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String path = '/login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInScreen(
        showAuthActionSwitch: true,
        actions: [
          ForgotPasswordAction((context, email) {
            context.push(
              ForgotPasswordAuthScreen.path,
              extra: email,
            );
          }),
          /*AuthStateChangeAction((context, state) {
            final user = switch (state) {
              SignedIn(user: final user) => user,
              UserCreated(credential: final cred) => cred.user,
              _ => null,
            };

            switch (user) {
              case User(emailVerified: true):
                context.push('/profile');
              case User(emailVerified: false, email: final String _):
                context.push('/verify-email');
            }
          }),*/
          AuthStateChangeAction<SignedIn>((context, state) {
            log('signed in user: ${state.user}');
            // saving user info to database
            getIt<SaveUser>()(params: state.user!);
            context.push(HomeScreen.path);
          }),
          AuthStateChangeAction<UserCreated>((context, state) {
            log('User created.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          })
        ],
        styles: const {
          EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
        },
        //headerBuilder: headerIcon(Icons.person),
        sideBuilder: sideIcon(Icons.lock),
        subtitleBuilder: (context, action) {
          final actionText = switch (action) {
            AuthAction.signIn => 'Please sign in to continue.',
            AuthAction.signUp => 'Please create an account to continue',
            _ => throw Exception('Invalid action: $action'),
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Welcome to Talk Hub! $actionText.'),
          );
        },
        footerBuilder: (context, action) {
          final actionText = switch (action) {
            AuthAction.signIn => 'signing in',
            AuthAction.signUp => 'registering',
            _ => throw Exception('Invalid action: $action'),
          };

          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'By $actionText, you agree to our terms and conditions.',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
