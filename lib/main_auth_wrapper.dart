import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/password_reset_screen.dart';
import 'screens/email_verification_screen.dart';
import 'services/auth_state_service.dart';
import 'theme/app_theme.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthStateService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_checkAuthState);
  }

  @override
  void dispose() {
    _authService.removeListener(_checkAuthState);
    super.dispose();
  }

  void _checkAuthState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat',
      theme: appTheme(),
      routes: {
        '/': (context) => const ChatScreen(),
        '/chat': (context) => const ChatScreen(),
        '/sign_in': (context) => const SignInScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/password_reset': (context) => const PasswordResetScreen(),
        '/email_verification': (context) => const EmailVerificationScreen(),
      },
      initialRoute: '/',
    );
  }
}
