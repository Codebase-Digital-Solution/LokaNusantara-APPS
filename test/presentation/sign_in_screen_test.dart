import 'package:bali_guide_map/domain/entities/user.dart';
import 'package:bali_guide_map/domain/usecases/auth_usecases.dart';
import 'package:bali_guide_map/presentation/providers/auth_provider.dart';
import 'package:bali_guide_map/presentation/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

/// Opens the sign-in screen from a button and records what it popped with.
Future<List<bool?>> _open(WidgetTester tester, FakeAuthRepository repo) async {
  final results = <bool?>[];
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        restoreSession: RestoreSessionUseCase(repo),
        loginWithGoogle: LoginWithGoogleUseCase(repo),
        logout: LogoutUseCase(repo),
      ),
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  testWidgets('offers only Google sign-in, no email or password', (
    tester,
  ) async {
    await _open(tester, FakeAuthRepository());
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('signing in with Google closes the screen with true', (
    tester,
  ) async {
    final repo = FakeAuthRepository(
      user: const User(id: 'u1', name: 'U', email: 'u@x'),
    );
    final results = await _open(tester, repo);
    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pumpAndSettle();
    expect(results, [true]);
  });

  testWidgets('closing the Google picker stays on the screen quietly', (
    tester,
  ) async {
    final results = await _open(tester, FakeAuthRepository()); // returns null
    await tester.tap(find.text('Lanjutkan dengan Google'));
    await tester.pumpAndSettle();
    expect(results, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
  });

  testWidgets('"Nanti saja" closes the screen with false', (tester) async {
    final results = await _open(tester, FakeAuthRepository());
    await tester.tap(find.text('Nanti saja'));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });
}
