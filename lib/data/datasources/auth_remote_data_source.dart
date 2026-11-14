import '../../core/api/api_client.dart';
import '../../domain/entities/auth_session.dart';
import '../models/models.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api);
  final ApiClient _api;

  /// Exchanges a Google ID token for our own session.
  Future<AuthSession> loginWithGoogle(String idToken) async {
    final res = await _api.post('/auth/google', data: {'id_token': idToken});
    return AuthSessionModel.fromJson(res as Json);
  }
}
