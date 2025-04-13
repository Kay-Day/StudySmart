import 'package:mongo_dart/mongo_dart.dart';

class Note {
  final ObjectId id;
  final String title;
  final String content;
  final ObjectId userId;
  final ObjectId? subjectId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    ObjectId? id,
    required this.title,
    required this.content,
    required this.userId,
    this.subjectId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? ObjectId(),
    tags = tags ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'subjectId': subjectId,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['_id'],
      title: map['title'],
      content: map['content'],
      userId: map['userId'],
      subjectId: map['subjectId'],
      tags: List<String>.from(map['tags']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}