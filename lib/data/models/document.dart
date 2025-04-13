import 'package:mongo_dart/mongo_dart.dart';

class Document {
  final ObjectId id;
  final String title;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final ObjectId userId;
  final ObjectId? subjectId;
  final List<String> tags;
  final DateTime uploadDate;
  final DateTime? lastAccessDate;

  Document({
    ObjectId? id,
    required this.title,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.userId,
    this.subjectId,
    List<String>? tags,
    DateTime? uploadDate,
    this.lastAccessDate,
  }) : 
    id = id ?? ObjectId(),
    tags = tags ?? [],
    uploadDate = uploadDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'userId': userId,
      'subjectId': subjectId,
      'tags': tags,
      'uploadDate': uploadDate,
      'lastAccessDate': lastAccessDate,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['_id'],
      title: map['title'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
      userId: map['userId'],
      subjectId: map['subjectId'],
      tags: List<String>.from(map['tags']),
      uploadDate: map['uploadDate'],
      lastAccessDate: map['lastAccessDate'],
    );
  }
}