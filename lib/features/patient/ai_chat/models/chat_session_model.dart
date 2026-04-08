class ChatSessionModel {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;

  ChatSessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
