// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '/features/AIChatPage/screens/chat_screen.dart';
// import '/features/AIChatPage/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/features/Transfinder/screens/RouteEditorScreen.dart';
import '/features/Transfinder/models/dataformat.dart';

Future<void> main() async {
  print('🚀 Starting Transfinder Route Editor...');
  
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded successfully');
    print('🔑 Google Maps API Key: ${dotenv.env['GOOGLE_MAPS_API_KEY']?.substring(0, 10)}...');
  } catch (e) {
    print('❌ Error loading .env file: $e');
  }
  
  runApp(
    MaterialApp(
      title: 'Transfinder Route Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardColor: const Color(0xFF1E1E1E),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardColor: const Color(0xFF1E1E1E),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      navigatorKey: GlobalKey<NavigatorState>(),
      home: const RouteEditorScreen(),
      routes: {
        '/route-editor': (context) => const RouteEditorScreen(),
      },
    ),
  );
}
