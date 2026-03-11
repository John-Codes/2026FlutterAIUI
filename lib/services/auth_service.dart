import 'package:flutter/material.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  String? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    _isAuthenticated = true;
    _currentUser = email;
    return true;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    _isAuthenticated = true;
    _currentUser = email;
    return true;
  }

  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 2));
    _isAuthenticated = true;
    _currentUser = 'google_user@example.com';
    return true;
  }

  Future<bool> signInWithFacebook() async {
    await Future.delayed(const Duration(seconds: 2));
    _isAuthenticated = true;
    _currentUser = 'facebook_user@example.com';
    return true;
  }

  Future<bool> signOut() async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = false;
    _currentUser = null;
    return true;
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> verifyEmail(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  void clearAuthState() {
    _isAuthenticated = false;
    _currentUser = null;
  }
}
