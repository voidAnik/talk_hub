import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub/core/error/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> saveUser({required User user});
}
