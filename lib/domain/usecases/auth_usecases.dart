import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthSession?> execute() => _repository.restoreSession();
}

class LoginWithGoogleUseCase {
  const LoginWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  /// Null means the user closed the Google account picker.
  Future<AuthSession?> execute() => _repository.loginWithGoogle();
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> execute() => _repository.logout();
}
