import 'package:mongo_dart/mongo_dart.dart';

class Subject {
  final ObjectId id;
  final String name;
  final String color; // Mã màu dưới dạng hex
  final ObjectId userId;
  final int targetHoursPerWeek;
  final String? icon;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
    ObjectId? id,
    required this.name,
    required this.color,
    required this.userId,
    required this.targetHoursPerWeek,
    this.icon,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? ObjectId(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'color': color,
      'userId': userId,
      'targetHoursPerWeek': targetHoursPerWeek,
      'icon': icon,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['_id'],
      name: map['name'],
      color: map['color'],
      userId: map['userId'],
      targetHoursPerWeek: map['targetHoursPerWeek'],
      icon: map['icon'],
      description: map['description'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}