import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub/core/error/exceptions.dart';
import 'package:talk_hub/core/error/failures.dart';

class ExceptionHandler {
  static Either<Failure, T> call<T>(Exception exception) {
    if (exception is FirebaseAuthException) {
      return Left(FirebaseFailure(
          message: exception.message ?? 'Authentication Error'));
    } else if (exception is FirebaseOperationException) {
      return Left(FirebaseFailure(message: exception.message));
    } else if (exception is NoInternetException) {
      return Left(NoInternetFailure(message: exception.message));
    } else {
      return const Left(InternalFailure(error: 'An unknown error occurred'));
    }
  }
}
