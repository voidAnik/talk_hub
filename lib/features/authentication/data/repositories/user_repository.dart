import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub/core/error/exceptions.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/features/authentication/data/data_sources/user_remote_data_source.dart';
import 'package:talk_hub/features/authentication/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> saveUser({required User user}) async {
    try {
      _dataSource.saveUser(user);
      return const Right(null);
    } on FirebaseOperationException catch (e) {
      return Left(FirebaseFailure(message: e.message));
    } catch (e) {
      return Left(InternalFailure(error: e.toString()));
    }
  }
}
