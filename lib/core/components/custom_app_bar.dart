import 'package:ai_diet_coach/core/utilies/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.shopName,
    this.actions,
  });

  final String shopName;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(shopName, style: AppTextStyles.title20BlackW600),
      centerTitle: true,
      actions: actions,
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
