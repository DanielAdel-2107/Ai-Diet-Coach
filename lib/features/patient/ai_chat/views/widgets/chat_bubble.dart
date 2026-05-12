import 'dart:ui';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final int index;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.height * 0.006),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _buildAvatar(context),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: _buildBubbleContent(context),
              ),
              if (isUser) ...[
                const SizedBox(width: 10),
                _buildUserAvatar(context),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5,
              left: isUser ? 0 : 54,
              right: isUser ? 54 : 0,
            ),
            child: Text(
              _formatTime(timestamp),
              style: AppTextStyles.title12Grey.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ).animate(
        delay: Duration(milliseconds: 80 * (index % 10)),
      ).fadeIn(
        duration: 400.ms,
        curve: Curves.easeOut,
      ).slideY(
        begin: 0.15,
        end: 0,
        duration: 450.ms,
        curve: Curves.easeOutQuart,
      ).scaleXY(
        begin: 0.94,
        end: 1,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    return isUser ? _buildUserBubble(context) : _buildAIBubble(context);
  }

  Widget _buildUserBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: SizeConfig.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark.withBlue(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Text(
        message,
        style: AppTextStyles.title14WhiteW600.copyWith(
          height: 1.45,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildAIBubble(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(5),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          constraints: BoxConstraints(maxWidth: SizeConfig.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.48),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(1.0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message,
            style: AppTextStyles.title14Black.copyWith(
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 18,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 18,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $amPm";
  }
}
