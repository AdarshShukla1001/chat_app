// lib/data/models/message_model.dart
import 'user_model.dart';

class MessageModel {
  final String id;
  final String groupId;
  final UserModel sender;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, bool>? seenBy;
  final Map<String, List<String>>? reactions;
  final String? parentMessage;
  final List<Attachment>? attachments;
  final bool deleted;
  final bool edited;

  MessageModel({
    required this.id,
    required this.groupId,
    required this.sender,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.seenBy,
    this.reactions,
    this.parentMessage,
    this.attachments = const [],
    this.deleted = false,
    this.edited = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      groupId: json['group'] is String ? json['group'] : json['group']['_id'],
      sender: json['sender'] is Map<String, dynamic> ? UserModel.fromJson(json['sender']) : UserModel(id: json['sender'], name: 'Unknown', email: ''),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      seenBy: (json['seenBy'] as Map?)?.map((key, value) => MapEntry(key.toString(), value)),
      reactions: (json['reactions'] as Map?)?.map((key, value) => MapEntry(key.toString(), List<String>.from(value))),
      parentMessage: json['parentMessage'],
      attachments: json['attachments'] != null ? List<Attachment>.from((json['attachments'] as List).map((e) => Attachment.fromJson(e))) : [],
      deleted: json['deleted'] ?? false,
      edited: json['edited'] ?? false,
    );
  }
}

class Attachment {
  final String type;
  final String url;
  final String? fileName;
  final String? mimeType;

  Attachment({required this.type, required this.url, this.fileName, this.mimeType});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(type: json['type'], url: json['url'], fileName: json['fileName'], mimeType: json['mimeType']);
  }
}
