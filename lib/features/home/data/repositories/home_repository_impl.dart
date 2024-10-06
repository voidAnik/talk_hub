import 'package:dartz/dartz.dart';
import 'package:talk_hub/core/error/exceptions.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';

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
}
