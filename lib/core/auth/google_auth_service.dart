import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../error/errors.dart';

/// Gets a Google ID token for the API to verify. Client IDs come from
/// `--dart-define` so no environment-specific value lives in the source:
///
/// ```sh
/// flutter run \
///   --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID \
///   --dart-define=GOOGLE_IOS_CLIENT_ID=IOS_CLIENT_ID
/// ```
///
/// GOOGLE_SERVER_CLIENT_ID must be the *Web* OAuth client ID; the API checks
/// that the token's audience matches it (GOOGLE_CLIENT_IDS on the server).
class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? signIn})
    : _signIn = signIn ?? GoogleSignIn.instance;

  // Web OAuth client of Firebase project lokanusantara-671f1. A client ID is
  // public (it ships inside every app build), so a default here is safe; a
  // --dart-define still overrides it, for example for a staging project.
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '845101561955-lv4r7q36i1o564pq45m1c1cnfo7gjjb3.apps.googleusercontent.com',
  );
  // iOS OAuth client (CLIENT_ID in ios/Runner/GoogleService-Info.plist). Its
  // reversed form is registered as a URL scheme in ios/Runner/Info.plist.
  static const iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '845101561955-hidkvgbk6h1d9c8t1tr2h6gclnbjgsf7.apps.googleusercontent.com',
  );

  /// False when the app was built without the Google client IDs; the login
  /// screens hide the Google button in that case.
  static bool get isConfigured =>
      serverClientId.isNotEmpty &&
      (defaultTargetPlatform != TargetPlatform.iOS || iosClientId.isNotEmpty);

  final GoogleSignIn _signIn;
  Future<void>? _init;

  Future<void> _ensureInitialized() => _init ??= _signIn.initialize(
    serverClientId: serverClientId,
    clientId: defaultTargetPlatform == TargetPlatform.iOS ? iosClientId : null,
  );

  /// Shows the Google account picker. Returns the ID token, or null when the
  /// user closes the picker.
  Future<String?> signIn() async {
    if (!isConfigured) {
      throw const AppError('Login Google belum dikonfigurasi', 'GOOGLE_CONFIG');
    }
    try {
      await _ensureInitialized();
      final account = await _signIn.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw const AppError('Google tidak mengirim ID token', 'GOOGLE_TOKEN');
      }
      return token;
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          return null;
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw AppError(
            'Konfigurasi login Google salah: ${e.description ?? e.code.name}',
            'GOOGLE_CONFIG',
          );
        default:
          throw AppError(
            'Login Google gagal: ${e.description ?? e.code.name}',
            'GOOGLE_ERROR',
          );
      }
    }
  }

  /// Forgets the chosen account so the picker shows again next time.
  Future<void> signOut() async {
    if (_init == null) return;
    try {
      await _signIn.signOut();
    } catch (_) {
      // Already signed out on the Google side.
    }
  }
}
