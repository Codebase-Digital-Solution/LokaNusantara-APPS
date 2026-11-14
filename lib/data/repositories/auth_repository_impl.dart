import '../../core/api/api_client.dart';
import '../../core/auth/google_auth_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import 'guard.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api, this._remote, this._local, this._google);

  final ApiClient _api;
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final GoogleAuthService _google;

  @override
  Future<AuthSession?> restoreSession() async {
    try {
      final session = await _local.read();
      if (session != null) _api.setToken(session.token);
      return session;
    } catch (_) {
      // Corrupt or unreadable storage: treat as logged out.
      return null;
    }
  }

  @override
  Future<AuthSession?> loginWithGoogle() => guard(() async {
    final idToken = await _google.signIn();
    if (idToken == null) return null;
    return _persist(await _remote.loginWithGoogle(idToken));
  });

  @override
  Future<void> logout() async {
    _api.clearToken();
    await _google.signOut();
    try {
      await _local.clear();
    } catch (_) {
      // Nothing to clean up.
    }
  }

  Future<AuthSession> _persist(AuthSession session) async {
    _api.setToken(session.token);
    await _local.save(session);
    return session;
  }
}
