import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this._restoreSession,
    required this._loginWithGoogle,
    required this._logout,
  });

  final RestoreSessionUseCase _restoreSession;
  final LoginWithGoogleUseCase _loginWithGoogle;
  final LogoutUseCase _logout;

  User? _user;
  bool _loading = false;
  AppError? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  AppError? get error => _error;

  Future<void> checkAuth() async {
    final session = await _restoreSession.execute();
    _user = session?.user;
    notifyListeners();
  }

  /// Returns true when signed in. False with a null [error] means the user
  /// cancelled the Google picker, so there is nothing to report.
  Future<bool> loginWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final session = await _loginWithGoogle.execute();
      if (session == null) return false;
      _user = session.user;
      return true;
    } catch (e) {
      _error = handleError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logout.execute();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
