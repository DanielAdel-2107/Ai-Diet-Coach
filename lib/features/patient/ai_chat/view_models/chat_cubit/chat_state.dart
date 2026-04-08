import 'package:ai_diet_coach/features/patient/ai_chat/models/chat_message_model.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/models/chat_session_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatHistoryLoaded extends ChatState {
  final List<ChatSessionModel> sessions;
  ChatHistoryLoaded(this.sessions);
}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final List<ChatSessionModel> sessions;
  final String? currentSessionId;
  final bool isTyping;

  ChatLoaded({
    required this.messages,
    this.sessions = const [],
    this.currentSessionId,
    this.isTyping = false,
  });
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
