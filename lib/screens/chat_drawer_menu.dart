import 'package:flutter/material.dart';
import '../widgets/navigation/app_drawer.dart';
import '../services/auth_state_service.dart';

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
    final authService = AuthStateService();

    return AppDrawer(
      onNavigateToSettings: onNavigateToSettings,
      onSignOut: onSignOut,
      isAuthenticated: authService.isAuthenticated,
    );
  }
}
