import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/models/chat_message_model.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/models/chat_session_model.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatCubit extends Cubit<ChatState> {
  final GeminiService _geminiService;
  final SupabaseClient _supabase;

  ChatCubit(this._geminiService, this._supabase) : super(ChatInitial());

  List<ChatMessageModel> _messages = [];
  List<ChatSessionModel> _sessions = [];
  String? _currentSessionId;

  Future<void> loadSessions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('chat_sessions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _sessions = (response as List)
          .map((json) => ChatSessionModel.fromJson(json))
          .toList();
      
      // Update state with current sessions if we are in ChatLoaded
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(ChatLoaded(
          messages: currentState.messages,
          sessions: _sessions,
          currentSessionId: _currentSessionId,
          isTyping: currentState.isTyping,
        ));
      } else {
        emit(ChatHistoryLoaded(_sessions));
      }
    } catch (e) {
      debugPrint("Error loading sessions: $e");
    }
  }

  Future<void> loadChatHistory() async {
    emit(ChatLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        initChat();
        return;
      }

      // Load all sessions first
      await loadSessions();

      if (_sessions.isNotEmpty) {
        // Load the most recent session by default
        await selectSession(_sessions.first.id);
      } else {
        initChat();
      }
    } catch (e) {
      emit(ChatError("Error loading history: ${e.toString()}"));
      initChat();
    }
  }

  void initChat() {
    final userId = _supabase.auth.currentUser?.id ?? "guest";
    _currentSessionId = null;
    _messages = [
      ChatMessageModel(
        userId: userId,
        message:
            "Hello! 👋 I'm your AI Nutrition & Fitness Coach. How can I help you today? Whether it's a diet plan, workout advice, or just a health question, I'm here for you!",
        isUser: false,
        createdAt: DateTime.now(),
      )
    ];
    emit(ChatLoaded(
      messages: List.from(_messages),
      sessions: _sessions,
      currentSessionId: _currentSessionId,
    ));
  }

  void startNewChat() {
    initChat();
  }

  Future<void> selectSession(String sessionId) async {
    emit(ChatLoading());
    try {
      _currentSessionId = sessionId;
      final response = await _supabase
          .from('ai_chats')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      _messages = (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();

      if (_messages.isEmpty) {
        _messages.add(ChatMessageModel(
          userId: _supabase.auth.currentUser?.id ?? "guest",
          message: "Welcome back to this session! How can I help you?",
          isUser: false,
          createdAt: DateTime.now(),
        ));
      }

      emit(ChatLoaded(
        messages: List.from(_messages),
        sessions: _sessions,
        currentSessionId: _currentSessionId,
      ));
    } catch (e) {
      emit(ChatError("Error loading session: $e"));
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _supabase.from('chat_sessions').delete().eq('id', sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
      
      if (_currentSessionId == sessionId) {
        startNewChat();
      } else {
        await loadSessions();
      }
    } catch (e) {
      emit(ChatError("Error deleting session: $e"));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final user = _supabase.auth.currentUser;
    final userId = user?.id ?? "guest";

    // 1. Create session if it doesn't exist
    if (_currentSessionId == null && user != null) {
      try {
        final sessionResponse = await _supabase.from('chat_sessions').insert({
          'user_id': userId,
          'title': text.length > 30 ? "${text.substring(0, 30)}..." : text,
        }).select().single();
        
        _currentSessionId = sessionResponse['id'];
        await loadSessions(); // Refresh session list
      } catch (e) {
        debugPrint("Error creating session: $e");
      }
    }

    final userMessage = ChatMessageModel(
      userId: userId,
      sessionId: _currentSessionId,
      message: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    // Update UI immediately (optimistic update)
    _messages.add(userMessage);
    emit(ChatLoaded(
      messages: List.from(_messages),
      sessions: _sessions,
      currentSessionId: _currentSessionId,
      isTyping: true,
    ));

    try {
      // 2. Save user message to Supabase if logged in
      if (user != null && _currentSessionId != null) {
        await _supabase.from('ai_chats').insert(userMessage.toJson());
      }

      // 3. Prepare context/history for Gemini
      // Filter for current session messages only (already in _messages)
      final historyList = _messages.length > 11 
          ? _messages.sublist(_messages.length - 11, _messages.length - 1)
          : _messages.take(_messages.length - 1)
                     .where((m) => _messages.indexOf(m) > 0 || m.isUser)
                     .toList();

      final history = historyList
          .map((m) => Content(m.isUser ? 'user' : 'model', [TextPart(m.message)]))
          .toList();

      // 4. Get AI response
      final aiResponseText = await _geminiService.chat(text, history: history);

      final aiMessage = ChatMessageModel(
        userId: userId,
        sessionId: _currentSessionId,
        message: aiResponseText,
        isUser: false,
        createdAt: DateTime.now(),
      );

      // 5. Save AI response to Supabase
      if (user != null && _currentSessionId != null) {
        await _supabase.from('ai_chats').insert(aiMessage.toJson());
      }

      _messages.add(aiMessage);
      emit(ChatLoaded(
        messages: List.from(_messages),
        sessions: _sessions,
        currentSessionId: _currentSessionId,
        isTyping: false,
      ));
    } catch (e) {
      emit(ChatError("Chat error: ${e.toString()}"));
      emit(ChatLoaded(
        messages: List.from(_messages),
        sessions: _sessions,
        currentSessionId: _currentSessionId,
        isTyping: false,
      ));
    }
  }
}
