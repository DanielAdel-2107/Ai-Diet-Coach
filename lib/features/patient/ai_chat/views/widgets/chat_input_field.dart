import 'dart:ui';
import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSend;
  final bool isTyping;

  const ChatInputField({
    super.key,
    required this.onSend,
    this.isTyping = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isTyping) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: _hasText ? AppColors.primary.withOpacity(0.3) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hasText 
                    ? AppColors.primary.withOpacity(0.08) 
                    : Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      enabled: !widget.isTyping,
                      style: AppTextStyles.title16BlackW500.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Ask anything about your health...",
                        hintStyle: AppTextStyles.title14Grey.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _handleSend,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: _hasText && !widget.isTyping
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.grey.shade200, Colors.grey.shade300],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: _hasText && !widget.isTyping
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.isTyping ? Icons.hourglass_empty_rounded : Icons.arrow_upward_rounded,
                      color: _hasText && !widget.isTyping ? Colors.white : Colors.grey.shade500,
                      size: 20,
                    ),
                  ).animate(target: _hasText ? 1 : 0).scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
