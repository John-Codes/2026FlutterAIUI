import 'package:flutter/material.dart';

class ChatMenuItems {
  static Widget createSettingsMenuItem({
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('Settings'),
      onTap: onTap,
    );
  }

  static Widget createCloseMenuItem({
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.close),
      title: const Text('Close'),
      onTap: onTap,
    );
  }
}
