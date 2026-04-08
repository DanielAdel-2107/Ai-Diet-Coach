import 'dart:ui';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_cubit.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.8),
            border: Border(
              right: BorderSide(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildNewChatButton(context),
                const Divider(color: Colors.white10),
                Expanded(child: _buildSessionList(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'AI History',
                style: AppTextStyles.title20WhiteBold.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your past conversations',
            style: AppTextStyles.title14Grey,
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.read<ChatCubit>().startNewChat();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Start New Chat',
                style: AppTextStyles.title16WhiteW600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final sessions = (state is ChatLoaded) 
            ? state.sessions 
            : (state is ChatHistoryLoaded ? state.sessions : []);
        final currentId = (state is ChatLoaded) ? state.currentSessionId : null;

        if (sessions.isEmpty) {
          return Center(
            child: Text(
              'No history yet',
              style: AppTextStyles.title14Grey,
            ),
          );
        }

        return ListView.builder(
          itemCount: sessions.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final session = sessions[index];
            final isSelected = session.id == currentId;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                onTap: () {
                  context.read<ChatCubit>().selectSession(session.id);
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.03),
                leading: Icon(
                  Icons.chat_bubble_outline,
                  color: isSelected ? AppColors.primary : Colors.white60,
                  size: 20,
                ),
                title: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, HH:mm').format(session.createdAt),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () {
                    context.read<ChatCubit>().deleteSession(session.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
