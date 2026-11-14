import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  /// Restores a persisted session, or returns null when there is none.
  Future<AuthSession?> restoreSession();

  /// Signs in with a Google account. Returns null when the user cancels.
  Future<AuthSession?> loginWithGoogle();
  Future<void> logout();
}
