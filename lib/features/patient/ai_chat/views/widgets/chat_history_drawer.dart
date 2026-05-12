import 'dart:ui';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_cubit.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_state.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/models/chat_session_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Drawer(
      backgroundColor: Colors.transparent,
      width: SizeConfig.width * 0.75,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.92),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            border: Border(
              right: BorderSide(
                color: AppColors.primary.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildNewChatButton(context),
                SizedBox(height: SizeConfig.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.width * 0.05,
                  ),
                  child: Text(
                    "RECENT CONVERSATIONS",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.height * 0.01),
                Expanded(child: _buildSessionList(context)),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.015),
            Text(
              'Chat History',
              style: AppTextStyles.title20BlackBold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Manage your AI consultations',
              style: AppTextStyles.title14Grey.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.04),
        child: InkWell(
          onTap: () {
            context.read<ChatCubit>().startNewChat();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.height * 0.015,
              horizontal: SizeConfig.width * 0.04,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: SizeConfig.width * 0.02),
                const Text(
                  'Start New Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textLight.withOpacity(0.2),
                  size: 48,
                ),
                SizedBox(height: SizeConfig.height * 0.02),
                Text(
                  'No history yet',
                  style: AppTextStyles.title14Grey.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: sessions.length,
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.03),
          itemBuilder: (context, index) {
            final session = sessions[index];
            final isSelected = session.id == currentId;

            return FadeInRight(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 400),
              child: _buildSessionTile(context, session, isSelected),
            );
          },
        );
      },
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    ChatSessionModel session,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<ChatCubit>().selectSession(session.id);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: isSelected ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textLight,
                    size: 18,
                  ),
                ),
                SizedBox(width: SizeConfig.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.8),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(session.createdAt),
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.error.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(context, session),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChatSessionModel session) {
    CustomQuickAlert.warning(
      title: "Delete History?",
      message: "This conversation will be permanently removed.",
      onConfirm: () {
        context.read<ChatCubit>().deleteSession(session.id);
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today, ${DateFormat('HH:mm').format(date)}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textLight, size: 16),
          const SizedBox(width: 8),
          Text(
            "Encrypted by AI Guard",
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
