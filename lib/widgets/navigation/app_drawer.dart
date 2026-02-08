import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onNavigateToSettings;

  const AppDrawer({
    super.key,
    required this.onNavigateToSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
            ),
            child: Text(
              'AI Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.white),
            title: const Text('Chat', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title:
                const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              onNavigateToSettings();
            },
          ),
        ],
      ),
    );
  }
}
