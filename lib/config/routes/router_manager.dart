import 'package:go_router/go_router.dart';
import 'package:talk_hub/config/routes/navigator_observer.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:talk_hub/features/authentication/presentation/screens/login_screen.dart';
import 'package:talk_hub/features/authentication/presentation/screens/user_profile_screen.dart';
import 'package:talk_hub/features/home/presentation/screens/home_screen.dart';
import 'package:talk_hub/features/hub/presentation/screens/audio_call_screen.dart';
import 'package:talk_hub/features/hub/presentation/screens/video_call_screen.dart';
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
          path: VideoCallScreen.path,
          builder: (context, state) => VideoCallScreen(
            user: state.extra is UserModel ? state.extra as UserModel : null,
            callId: state.extra is String ? state.extra as String : null,
          ),
        ),
        GoRoute(
            path: AudioCallScreen.path,
            builder: (context, state) {
              if (state.extra is (UserModel, String)) {
                final value = state.extra as (UserModel, String);
                return AudioCallScreen(
                  user: value.$1,
                  callId: value.$2,
                );
              } else {
                return AudioCallScreen(
                  user: state.extra as UserModel,
                );
              }
            }),
      ]);
}
