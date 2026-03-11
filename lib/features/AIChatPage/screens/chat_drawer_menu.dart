import 'package:flutter/material.dart';
import '../widgets/navigation/app_drawer.dart';

class ChatDrawerMenu extends StatelessWidget {
  final VoidCallback onNavigateToSettings;
  final VoidCallback onSignOut;

  const ChatDrawerMenu({
    super.key,
    required this.onNavigateToSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return AppDrawer(
      onNavigateToSettings: onNavigateToSettings,
      onSignOut: onSignOut,
      isAuthenticated:
          true, // Always authenticated since we go directly to chat
    );
  }
}
