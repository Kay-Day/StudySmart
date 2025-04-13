import 'package:mongo_dart/mongo_dart.dart';

class StudySession {
  final ObjectId id;
  final ObjectId userId;
  final ObjectId subjectId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String? notes;
  final int productivityRating; // 1-5 rating
  final DateTime createdAt;

  StudySession({
    ObjectId? id,
    required this.userId,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.notes,
    required this.productivityRating,
    DateTime? createdAt,
  }) : 
    id = id ?? ObjectId(),
    createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'subjectId': subjectId,
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'productivityRating': productivityRating,
      'createdAt': createdAt,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['_id'],
      userId: map['userId'],
      subjectId: map['subjectId'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      durationMinutes: map['durationMinutes'],
      notes: map['notes'],
      productivityRating: map['productivityRating'],
      createdAt: map['createdAt'],
    );
  }
}