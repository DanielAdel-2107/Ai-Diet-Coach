class ChatMessageModel {
  final String? id;
  final String userId;
  final String? sessionId;
  final String message;
  final bool isUser;
  final DateTime createdAt;

  ChatMessageModel({
    this.id,
    required this.userId,
    this.sessionId,
    required this.message,
    required this.isUser,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString(),
      userId: json['user_id'],
      sessionId: json['session_id'],
      message: json['message'],
      isUser: json['is_user'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      'message': message,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
