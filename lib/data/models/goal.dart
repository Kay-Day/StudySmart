import 'package:mongo_dart/mongo_dart.dart';

enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  failed
}

extension GoalStatusExtension on GoalStatus {
  String get name {
    switch (this) {
      case GoalStatus.notStarted:
        return 'Chưa bắt đầu';
      case GoalStatus.inProgress:
        return 'Đang thực hiện';
      case GoalStatus.completed:
        return 'Hoàn thành';
      case GoalStatus.failed:
        return 'Không đạt';
    }
  }
}

class Goal {
  final ObjectId id;
  final String title;
  final String description;
  final ObjectId userId;
  final ObjectId? subjectId; // Có thể null nếu mục tiêu không gắn với môn học
  final DateTime deadline;
  final GoalStatus status;
  final int progressPercentage; // 0-100
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    ObjectId? id,
    required this.title,
    required this.description,
    required this.userId,
    this.subjectId,
    required this.deadline,
    required this.status,
    required this.progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? ObjectId(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'subjectId': subjectId,
      'deadline': deadline,
      'status': status.index,
      'progressPercentage': progressPercentage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['_id'],
      title: map['title'],
      description: map['description'],
      userId: map['userId'],
      subjectId: map['subjectId'],
      deadline: map['deadline'],
      status: GoalStatus.values[map['status']],
      progressPercentage: map['progressPercentage'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}