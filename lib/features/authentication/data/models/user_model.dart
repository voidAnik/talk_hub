import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? uid;
  final bool? isEmailVerified;
  final bool? isOnline;

  UserModel(
      {this.name,
      this.email,
      this.photoUrl,
      this.uid,
      this.isEmailVerified,
      this.isOnline});

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? uid,
    bool? isEmailVerified,
    bool? isOnline,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      uid: uid ?? this.uid,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  static UserModel fromUser(User user) {
    return UserModel(
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      uid: user.uid,
      isEmailVerified: user.emailVerified,
      isOnline: true,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"],
      email: json["email"],
      photoUrl: json["photoUrl"],
      uid: json["uid"],
      isEmailVerified: json["isEmailVerified"].toLowerCase() == 'true',
      isOnline: json["isOnline"].toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "photoUrl": photoUrl,
      "uid": uid,
      "isEmailVerified": isEmailVerified,
      "isOnline": isOnline,
    };
  }

  @override
  String toString() {
    return 'UserModel{name: $name, email: $email, photoUrl: $photoUrl, uid: $uid, isEmailVerified: $isEmailVerified, isOnline: $isOnline}';
  }
}
