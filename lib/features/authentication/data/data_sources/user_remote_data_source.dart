import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub/core/error/exceptions.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> saveUser(User user);
}

class UserRemoteDataSourceImpl extends UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> saveUser(User user) async {
    UserModel userModel = UserModel.fromUser(user);
    final userDoc = _firestore.collection('users').doc(user.uid);
    await userDoc.set(userModel.toMap()).then((_) {
      log('user saved: $userModel');
    }).catchError((error) {
      log('user saving error: $error');
      throw FirebaseOperationException(message: error.toString());
    });
  }
}
