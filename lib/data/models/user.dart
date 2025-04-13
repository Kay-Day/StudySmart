import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId id;
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    ObjectId? id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? ObjectId(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      fullName: map['fullName'],
      avatarUrl: map['avatarUrl'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}