import 'package:go_router/go_router.dart';
import 'package:talk_hub/config/routes/navigator_observer.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:talk_hub/features/authentication/presentation/screens/login_screen.dart';
import 'package:talk_hub/features/authentication/presentation/screens/user_profile_screen.dart';
import 'package:talk_hub/features/home/presentation/screens/home_screen.dart';
import 'package:talk_hub/features/hub/presentation/screens/call_screen.dart';
import 'package:talk_hub/features/splash/presentation/splash_screen.dart';

class RouterManager {
  static final config = GoRouter(
      observers: [
        CustomNavigatorObserver(),
      ],
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: LoginScreen.path,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: UserProfileScreen.path,
          builder: (context, state) => UserProfileScreen(),
        ),
        GoRoute(
          path: ForgotPasswordAuthScreen.path,
          builder: (context, state) => ForgotPasswordAuthScreen(
            email: state.extra as String,
          ),
        ),
        GoRoute(
          path: HomeScreen.path,
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: CallScreen.path,
          builder: (context, state) =>
              CallScreen(user: state.extra as UserModel),
        ),
      ]);
}
