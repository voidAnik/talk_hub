class FirebaseAuthException implements Exception {
  final String message;

  FirebaseAuthException({required this.message});
}

class FirebaseOperationException implements Exception {
  final String message;

  FirebaseOperationException({required this.message});
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException({required this.message});
}
