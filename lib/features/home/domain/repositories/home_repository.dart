import 'package:dartz/dartz.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';
import 'package:talk_hub/features/hub/data/models/incoming_call.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<RoomModel>>> getRooms();
  Future<Either<Failure, List<UserModel>>> getUsers();
  Stream<Either<Failure, String>> listenIncomingCall();
  Future<Either<Failure, IncomingCall>> getCallerInfo({required String callId});
}
