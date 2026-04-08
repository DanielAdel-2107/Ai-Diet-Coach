import 'package:ai_diet_coach/core/di/dependancy_injection.dart';
import 'package:ai_diet_coach/core/network/api/gemini_service.dart';
import 'package:ai_diet_coach/core/widgets/immersive_background.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_cubit.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/views/widgets/chat_body.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/views/widgets/chat_history_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        getIt<GeminiService>(),
        getIt<SupabaseClient>(),
      )..loadChatHistory(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: const ChatHistoryDrawer(),
        body: const ImmersiveBackground(
          child: ChatBody(),
        ),
      ),
    );
  }
}
