import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.properties = const <dynamic>[]});

  final List properties;

  @override
  List<Object> get props => [properties];
}

class FirebaseAuthFailure extends Failure {
  final String error;

  const FirebaseAuthFailure({required this.error});
}

class FirebaseOperationFailure extends Failure {
  final String error;

  const FirebaseOperationFailure({required this.error});
}

class NoInternetFailure extends Failure {
  final String error;

  const NoInternetFailure({required this.error});
}
