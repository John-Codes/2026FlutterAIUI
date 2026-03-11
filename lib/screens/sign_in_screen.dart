import 'package:flutter/material.dart';
import '../services/auth_state_service.dart';
import '../services/auth_logging_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthStateService();
  final _authLoggingService = AuthLoggingService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    _authLoggingService.logSignInAttempt(email);
    _authLoggingService
        .logApiCall('/auth/signin', 'POST', params: {'email': email});

    setState(() => _isLoading = true);

    try {
      final success = await _authService.signIn(
        email: email,
        password: _passwordController.text,
      );

      if (success && mounted) {
        _authLoggingService.logSignInSuccess(email);
        _authLoggingService.logApiResponse('/auth/signin', 200);
        Navigator.pop(context);
      }
    } catch (e) {
      _authLoggingService.logSignInFailure(email, e.toString());
      _authLoggingService.logApiResponse('/auth/signin', 400,
          error: e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      _authLoggingService.logOAuthSignInAttempt('Google', null);
      _authLoggingService.logApiCall('/auth/google', 'POST');

      final success = await _authService.signInWithGoogle();

      if (success && mounted) {
        _authLoggingService.logOAuthSignInSuccess(
            'Google', 'google_user@example.com');
        _authLoggingService.logApiResponse('/auth/google', 200);
        Navigator.pop(context);
      }
    } catch (e) {
      _authLoggingService.logOAuthSignInFailure('Google', null, e.toString());
      _authLoggingService.logApiResponse('/auth/google', 400,
          error: e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignInWithFacebook() async {
    setState(() => _isLoading = true);

    try {
      _authLoggingService.logOAuthSignInAttempt('Facebook', null);
      _authLoggingService.logApiCall('/auth/facebook', 'POST');

      final success = await _authService.signInWithFacebook();

      if (success && mounted) {
        _authLoggingService.logOAuthSignInSuccess(
            'Facebook', 'facebook_user@example.com');
        _authLoggingService.logApiResponse('/auth/facebook', 200);
        Navigator.pop(context);
      }
    } catch (e) {
      _authLoggingService.logOAuthSignInFailure('Facebook', null, e.toString());
      _authLoggingService.logApiResponse('/auth/facebook', 400,
          error: e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facebook sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMagicLinkSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    _authLoggingService.logMagicLinkSignInAttempt(email);
    _authLoggingService
        .logApiCall('/auth/magic-link', 'POST', params: {'email': email});

    setState(() => _isLoading = true);

    try {
      // Stub for magic link authentication - would call your Supabase backend
      await Future.delayed(const Duration(seconds: 2));

      _authLoggingService.logMagicLinkSignInSuccess(email);
      _authLoggingService.logApiResponse('/auth/magic-link', 200);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Magic link sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _authLoggingService.logSignInFailure(email, e.toString());
      _authLoggingService.logApiResponse('/auth/magic-link', 400,
          error: e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Magic link failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignInWithApple() async {
    setState(() => _isLoading = true);

    try {
      _authLoggingService.logOAuthSignInAttempt('Apple', null);
      _authLoggingService.logApiCall('/auth/apple', 'POST');

      // Stub for Apple OAuth authentication
      await Future.delayed(const Duration(seconds: 2));

      _authLoggingService.logOAuthSignInSuccess(
          'Apple', 'apple_user@example.com');
      _authLoggingService.logApiResponse('/auth/apple', 200);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple sign in successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _authLoggingService.logOAuthSignInFailure('Apple', null, e.toString());
      _authLoggingService.logApiResponse('/auth/apple', 400,
          error: e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignInWithAndroid() async {
    setState(() => _isLoading = true);

    try {
      _authLoggingService.logOAuthSignInAttempt('Android', null);
      _authLoggingService.logApiCall('/auth/android', 'POST');

      // Stub for Android OAuth authentication
      await Future.delayed(const Duration(seconds: 2));

      _authLoggingService.logOAuthSignInSuccess(
          'Android', 'android_user@example.com');
      _authLoggingService.logApiResponse('/auth/android', 200);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Android sign in successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _authLoggingService.logOAuthSignInFailure('Android', null, e.toString());
      _authLoggingService.logApiResponse('/auth/android', 400,
          error: e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Android sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sign In'),
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleSignInWithGoogle,
                      icon: const Icon(Icons.gpp_good, color: Colors.white),
                      label: const Text('Google',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleSignInWithFacebook,
                      icon: const Icon(Icons.facebook, color: Colors.white),
                      label: const Text('Facebook',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleSignInWithApple,
                      icon: const Icon(Icons.apple, color: Colors.white),
                      label: const Text('Apple',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleSignInWithAndroid,
                      icon: const Icon(Icons.android, color: Colors.white),
                      label: const Text('Android',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleMagicLinkSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign In with Magic Link'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
