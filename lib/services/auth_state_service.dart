import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'auth_logging_service.dart';

class AuthStateService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthLoggingService _authLoggingService = AuthLoggingService();

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get currentUser => _authService.currentUser;

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _authLoggingService.logSignUpAttempt(email, name);
    _authLoggingService.logApiCall('/auth/signup', 'POST', params: {
      'email': email,
      'name': name,
    });

    try {
      final success = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (success) {
        _authLoggingService.logSignUpSuccess(email, name);
        _authLoggingService.logApiResponse('/auth/signup', 200);
      }

      notifyListeners();
      return success;
    } catch (e) {
      _authLoggingService.logSignUpFailure(email, name, e.toString());
      _authLoggingService.logApiResponse('/auth/signup', 400,
          error: e.toString());
      rethrow;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _authLoggingService.logSignInAttempt(email);
    _authLoggingService
        .logApiCall('/auth/signin', 'POST', params: {'email': email});

    try {
      final success = await _authService.signIn(
        email: email,
        password: password,
      );

      if (success) {
        _authLoggingService.logSignInSuccess(email);
        _authLoggingService.logApiResponse('/auth/signin', 200);
      }

      notifyListeners();
      return success;
    } catch (e) {
      _authLoggingService.logSignInFailure(email, e.toString());
      _authLoggingService.logApiResponse('/auth/signin', 400,
          error: e.toString());
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    _authLoggingService.logOAuthSignInAttempt('Google', null);
    _authLoggingService.logApiCall('/auth/google', 'POST');

    try {
      final success = await _authService.signInWithGoogle();

      if (success) {
        _authLoggingService.logOAuthSignInSuccess(
            'Google', 'google_user@example.com');
        _authLoggingService.logApiResponse('/auth/google', 200);
      }

      notifyListeners();
      return success;
    } catch (e) {
      _authLoggingService.logOAuthSignInFailure('Google', null, e.toString());
      _authLoggingService.logApiResponse('/auth/google', 400,
          error: e.toString());
      rethrow;
    }
  }

  Future<bool> signInWithFacebook() async {
    _authLoggingService.logOAuthSignInAttempt('Facebook', null);
    _authLoggingService.logApiCall('/auth/facebook', 'POST');

    try {
      final success = await _authService.signInWithFacebook();

      if (success) {
        _authLoggingService.logOAuthSignInSuccess(
            'Facebook', 'facebook_user@example.com');
        _authLoggingService.logApiResponse('/auth/facebook', 200);
      }

      notifyListeners();
      return success;
    } catch (e) {
      _authLoggingService.logOAuthSignInFailure('Facebook', null, e.toString());
      _authLoggingService.logApiResponse('/auth/facebook', 400,
          error: e.toString());
      rethrow;
    }
  }

  Future<bool> signOut() async {
    final currentUser = _authService.currentUser;
    _authLoggingService.logSignOutAttempt(currentUser);
    _authLoggingService.logApiCall('/auth/signout', 'POST');

    try {
      final success = await _authService.signOut();

      if (success) {
        _authLoggingService.logSignOutSuccess(currentUser);
        _authLoggingService.logApiResponse('/auth/signout', 200);
      }

      notifyListeners();
      return success;
    } catch (e) {
      _authLoggingService.logSignOutFailure(currentUser, e.toString());
      _authLoggingService.logApiResponse('/auth/signout', 400,
          error: e.toString());
      rethrow;
    }
  }

  Future<bool> resetPassword(String email) async {
    _authLoggingService.logPasswordResetAttempt(email);
    _authLoggingService
        .logApiCall('/auth/reset-password', 'POST', params: {'email': email});

    try {
      final success = await _authService.resetPassword(email);

      if (success) {
        _authLoggingService.logPasswordResetSuccess(email);
        _authLoggingService.logApiResponse('/auth/reset-password', 200);
      }

      return success;
    } catch (e) {
      _authLoggingService.logPasswordResetFailure(email, e.toString());
      _authLoggingService.logApiResponse('/auth/reset-password', 400,
          error: e.toString());
      rethrow;
    }
  }

  Future<bool> verifyEmail(String email) async {
    _authLoggingService.logEmailVerificationAttempt(email);
    _authLoggingService
        .logApiCall('/auth/verify-email', 'POST', params: {'email': email});

    try {
      final success = await _authService.verifyEmail(email);

      if (success) {
        _authLoggingService.logEmailVerificationSuccess(email);
        _authLoggingService.logApiResponse('/auth/verify-email', 200);
      }

      return success;
    } catch (e) {
      _authLoggingService.logEmailVerificationFailure(email, e.toString());
      _authLoggingService.logApiResponse('/auth/verify-email', 400,
          error: e.toString());
      rethrow;
    }
  }

  void clearAuthState() {
    _authService.clearAuthState();
    notifyListeners();
  }
}
