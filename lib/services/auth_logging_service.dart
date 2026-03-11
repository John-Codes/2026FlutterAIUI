/// Authentication logging service for tracking auth events
/// Follows SRP by handling only auth-related logging functionality
class AuthLoggingService {
  static final AuthLoggingService _instance = AuthLoggingService._internal();
  factory AuthLoggingService() => _instance;
  AuthLoggingService._internal();

  /// Log sign in attempt
  void logSignInAttempt(String email) {
    print('[AUTH] Sign in attempt for: $email');
  }

  /// Log successful sign in
  void logSignInSuccess(String email) {
    print('[AUTH] Sign in successful for: $email');
  }

  /// Log sign in failure
  void logSignInFailure(String email, String error) {
    print('[AUTH] Sign in failed for: $email - Error: $error');
  }

  /// Log magic link sign in attempt
  void logMagicLinkSignInAttempt(String email) {
    print('[AUTH] Magic link sign in attempt for: $email');
  }

  /// Log magic link sign in success
  void logMagicLinkSignInSuccess(String email) {
    print('[AUTH] Magic link sign in successful for: $email');
  }

  /// Log sign up attempt
  void logSignUpAttempt(String email, String? name) {
    print('[AUTH] Sign up attempt for: $email, name: $name');
  }

  /// Log successful sign up
  void logSignUpSuccess(String email, String? name) {
    print('[AUTH] Sign up successful for: $email, name: $name');
  }

  /// Log sign up failure
  void logSignUpFailure(String email, String? name, String error) {
    print('[AUTH] Sign up failed for: $email, name: $name - Error: $error');
  }

  /// Log password reset attempt
  void logPasswordResetAttempt(String email) {
    print('[AUTH] Password reset attempt for: $email');
  }

  /// Log password reset success
  void logPasswordResetSuccess(String email) {
    print('[AUTH] Password reset email sent for: $email');
  }

  /// Log password reset failure
  void logPasswordResetFailure(String email, String error) {
    print('[AUTH] Password reset failed for: $email - Error: $error');
  }

  /// Log email verification attempt
  void logEmailVerificationAttempt(String email) {
    print('[AUTH] Email verification attempt for: $email');
  }

  /// Log email verification success
  void logEmailVerificationSuccess(String email) {
    print('[AUTH] Email verification email sent for: $email');
  }

  /// Log email verification failure
  void logEmailVerificationFailure(String email, String error) {
    print('[AUTH] Email verification failed for: $email - Error: $error');
  }

  /// Log OAuth provider sign in attempt
  void logOAuthSignInAttempt(String provider, String? email) {
    print('[AUTH] OAuth sign in attempt with $provider for: $email');
  }

  /// Log OAuth provider sign in success
  void logOAuthSignInSuccess(String provider, String? email) {
    print('[AUTH] OAuth sign in successful with $provider for: $email');
  }

  /// Log OAuth provider sign in failure
  void logOAuthSignInFailure(String provider, String? email, String error) {
    print(
        '[AUTH] OAuth sign in failed with $provider for: $email - Error: $error');
  }

  /// Log sign out attempt
  void logSignOutAttempt(String? email) {
    print('[AUTH] Sign out attempt for: $email');
  }

  /// Log successful sign out
  void logSignOutSuccess(String? email) {
    print('[AUTH] Sign out successful for: $email');
  }

  /// Log sign out failure
  void logSignOutFailure(String? email, String error) {
    print('[AUTH] Sign out failed for: $email - Error: $error');
  }

  /// Log API call stub
  void logApiCall(String endpoint, String method,
      {Map<String, dynamic>? params}) {
    print(
        '[API] $method $endpoint${params != null ? ' - Params: $params' : ''}');
  }

  /// Log API response
  void logApiResponse(String endpoint, int statusCode,
      {String? response, String? error}) {
    if (error != null) {
      print(
          '[API] Response from $endpoint - Status: $statusCode - Error: $error');
    } else {
      print(
          '[API] Response from $endpoint - Status: $statusCode - Success: ${response?.substring(0, response.length < 100 ? response.length : 100) ?? 'Empty'}');
    }
  }
}
