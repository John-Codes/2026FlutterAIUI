import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onNavigateToSettings;
  final VoidCallback onSignOut;
  final bool isAuthenticated;

  const AppDrawer({
    super.key,
    required this.onNavigateToSettings,
    required this.onSignOut,
    required this.isAuthenticated,
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
          if (isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.white),
              title: const Text('Chat', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Log Out', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onSignOut();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login, color: Colors.white),
              title:
                  const Text('Sign In', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/sign_in');
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration, color: Colors.white),
              title:
                  const Text('Sign Up', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/sign_up');
              },
            ),
          ],
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
