import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/core/use_case/use_case.dart';
import 'package:talk_hub/features/authentication/domain/repositories/user_repository.dart';

class SaveUser extends UseCase<void, User> {
  final UserRepository _repository;

  SaveUser(this._repository);

  @override
  Future<Either<Failure, void>?> call({required User params}) {
    return _repository.saveUser(user: params);
  }
}
