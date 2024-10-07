import 'package:talk_hub/features/authentication/data/models/user_model.dart';

class IncomingCall {
  UserModel user;
  String callType;
  String callId;

  IncomingCall({
    required this.user,
    required this.callType,
    required this.callId,
  });

  @override
  String toString() {
    return 'IncomingCall{user: $user, callType: $callType, callId: $callId}';
  }
}
