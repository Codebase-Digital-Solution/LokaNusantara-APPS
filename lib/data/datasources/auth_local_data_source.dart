import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../models/models.dart';

/// Persists the JWT and user profile in the platform keychain/keystore.
class AuthLocalDataSource {
  const AuthLocalDataSource([this._storage = const FlutterSecureStorage()]);
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'auth_user';

  Future<AuthSession?> read() async {
    final token = await _storage.read(key: _tokenKey);
    final userJson = await _storage.read(key: _userKey);
    if (token == null || userJson == null) return null;
    return AuthSession(
      user: UserModel.fromJson(jsonDecode(userJson) as Json),
      token: token,
    );
  }

  Future<void> save(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(UserModel.toJson(session.user)),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
