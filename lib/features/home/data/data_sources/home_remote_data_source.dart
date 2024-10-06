import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub/core/error/exceptions.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<RoomModel>> fetchRooms();
  Future<List<UserModel>> fetchUsers();
}

class HomeRemoteDataSourceImpl extends HomeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HomeRemoteDataSourceImpl(this._firestore, this._auth);

  @override
  Future<List<RoomModel>> fetchRooms() async {
    try {
      final roomCollection = await _firestore.collection('rooms').get();
      return roomCollection.docs
          .map((doc) => RoomModel.fromMap(doc.data()))
          .toList();
    } catch (error) {
      log('Error fetching rooms: $error');
      throw FirebaseOperationException(message: error.toString());
    }
  }

  @override
  Future<List<UserModel>> fetchUsers() async {
    try {
      final userCollection = await _firestore.collection('users').get();
      return userCollection.docs
          .where((doc) =>
              doc.id != _auth.currentUser!.uid) // Filter out the current user
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (error) {
      log('Error fetching users: $error');
      throw FirebaseOperationException(message: error.toString());
    }
  }
}
