import 'package:animate_do/animate_do.dart';
import 'package:ai_diet_coach/core/utilies/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utilies/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_cubit.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/view_models/chat_cubit/chat_state.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/views/widgets/chat_bubble.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/views/widgets/chat_input_field.dart';
import 'package:ai_diet_coach/features/patient/ai_chat/views/widgets/glassmorphic_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    "Weight loss tips 🥗",
    "Sugar level guide 🩸",
    "Healthy recipes 🍏",
    "Workout routine 🏋️",
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        String title = "AI Coach";
        if (state is ChatLoaded && state.currentSessionId != null) {
          try {
            final currentSession = state.sessions.firstWhere(
              (s) => s.id == state.currentSessionId,
            );
            title = currentSession.title;
          } catch (_) {
            title = "New Chat";
          }
        }

          return Container(
            color: AppColors.scaffoldBackground,
            child: Stack(
              children: [
                // Decorative background blobs
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: SizeConfig.width * 0.8,
                    height: SizeConfig.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.04),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  left: -50,
                  child: Container(
                    width: SizeConfig.width * 0.6,
                    height: SizeConfig.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withOpacity(0.03),
                    ),
                  ),
                ),
                Column(
                  children: [
                    GlassmorphicAppBar(
                      title: title,
                      subtitle: "Online Assistance",
                      onBack: () => Navigator.pop(context),
                      leading: IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                          onPressed: () => context.read<ChatCubit>().startNewChat(),
                          tooltip: 'New Chat',
                        ),
                      ],
                    ),
                    Expanded(
                      child: BlocConsumer<ChatCubit, ChatState>(
                        listener: (context, state) {
                          if (state is ChatLoaded) {
                            _scrollToBottom();
                          }
                          if (state is ChatError) {
                            CustomQuickAlert.error(
                              title: "Oops!",
                              message: state.message,
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is ChatLoading) {
                            return Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: AppColors.primary,
                                size: 50,
                              ),
                            );
                          }

                          List<dynamic> messages = [];
                          bool isTyping = false;

                          if (state is ChatLoaded) {
                            messages = state.messages;
                            isTyping = state.isTyping;
                          }

                          return Stack(
                            children: [
                              ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.only(
                                  left: SizeConfig.width * 0.05,
                                  right: SizeConfig.width * 0.05,
                                  top: 10,
                                  bottom: 160, 
                                ),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  return ChatBubble(
                                    message: msg.message,
                                    isUser: msg.isUser,
                                    timestamp: msg.createdAt,
                                    index: index,
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isTyping)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20, bottom: 8),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: FadeInLeft(
                                            duration: const Duration(milliseconds: 400),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  LoadingAnimationWidget.waveDots(
                                                    color: AppColors.primary,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "Coach is thinking...",
                                                    style: AppTextStyles.title12Grey.copyWith(
                                                      fontStyle: FontStyle.italic,
                                                      color: AppColors.primary.withOpacity(0.85),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    _buildSuggestions(isTyping),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        bool isTyping = false;
                        if (state is ChatLoaded) isTyping = state.isTyping;
                        return ChatInputField(
                          onSend: (text) => context.read<ChatCubit>().sendMessage(text),
                          isTyping: isTyping,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
      },
    );
  }

  Widget _buildSuggestions(bool isTyping) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: isTyping ? 0.0 : 1.0, // Hide suggestions when typing for focus
      child: IgnorePointer(
        ignoring: isTyping,
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: Container(
            height: 46,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.read<ChatCubit>().sendMessage(_suggestions[index]),
                      borderRadius: BorderRadius.circular(23),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.12),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _suggestions[index],
                            style: AppTextStyles.title14PrimaryColor.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate()
                 .fadeIn(delay: (100 * index).ms)
                 .slideX(begin: 0.2, end: 0);
              },
            ),
          ),
        ),
      ),
    );
  }
}
