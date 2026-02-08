import 'package:flutter/material.dart';
import '../widgets/navigation/app_drawer.dart';

class ChatDrawerMenu extends StatelessWidget {
  final VoidCallback onNavigateToSettings;

  const ChatDrawerMenu({
    super.key,
    required this.onNavigateToSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppDrawer(
      onNavigateToSettings: onNavigateToSettings,
    );
  }
}
