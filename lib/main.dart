import 'package:flutter/material.dart';
import '/features/AIChatPage/screens/chat_screen.dart';
import '/features/AIChatPage/theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'AI Chat',
      theme: appTheme(),
      navigatorKey: GlobalKey<NavigatorState>(),
      home: const ChatScreen(),
      routes: {
        '/chat': (context) => const ChatScreen(),
      },
    ),
  );
}
