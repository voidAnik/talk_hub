import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_hub/features/authentication/presentation/screens/login_screen.dart';

class UserProfileScreen extends ProfileScreen {
  static const String path = '/profile_screen';
  UserProfileScreen({super.key})
      : super(
          actions: [
            SignedOutAction((context) {
              context.push(LoginScreen.path);
            }),
          ],
          //actionCodeSettings: actionCodeSettings,
          /*showMFATile: kIsWeb ||
                context.theme.platform == TargetPlatform.iOS ||
                context.theme.platform == TargetPlatform.android,*/
          showUnlinkConfirmationDialog: true,
          showDeleteConfirmationDialog: true,
        );
}
