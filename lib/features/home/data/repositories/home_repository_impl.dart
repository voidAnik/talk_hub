import 'package:dartz/dartz.dart';
import 'package:talk_hub/core/error/exceptions.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';
import 'package:talk_hub/features/hub/data/models/incoming_call.dart';

class HomeRepositoryImpl extends HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<RoomModel>>> getRooms() async {
    try {
      final rooms = await _remoteDataSource.fetchRooms();
      return Right(rooms);
    } on FirebaseOperationException catch (e) {
      return Left(FirebaseFailure(message: e.message));
    } catch (e) {
      return Left(InternalFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getUsers() async {
    try {
      final users = await _remoteDataSource.fetchUsers();
      return Right(users);
    } on FirebaseOperationException catch (e) {
      return Left(FirebaseFailure(message: e.message));
    } catch (e) {
      return Left(InternalFailure(error: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, String>> listenIncomingCall() async* {
    try {
      await for (var callId in _remoteDataSource.listenIncomingCall()) {
        yield Right(callId);
      }
    } on FirebaseOperationException catch (e) {
      yield Left(FirebaseFailure(message: e.message));
    } catch (e) {
      yield Left(InternalFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, IncomingCall>> getCallerInfo(
      {required String callId}) async {
    try {
      final incomingCallInfo = await _remoteDataSource.getCallerInfo(callId);
      return Right(incomingCallInfo);
    } on FirebaseOperationException catch (e) {
      return Left(FirebaseFailure(message: e.message));
    } catch (e) {
      return Left(InternalFailure(error: e.toString()));
    }
  }
}
