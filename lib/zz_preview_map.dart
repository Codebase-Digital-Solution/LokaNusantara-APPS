import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/service_locator.dart';
import 'presentation/app.dart';
import 'presentation/navigation/map_navigation.dart';
import 'presentation/screens/main_shell.dart';

// Temporary preview: skips onboarding and taps the map button after a while.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
  runApp(LokaNusantaraApp(locator: ServiceLocator()));
  Future<void> cycle() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    Element? shell;
    void visit(Element e) {
      if (shell != null) return;
      if (e.widget is MainShell) {
        shell = e;
        return;
      }
      e.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    if (shell != null) {
      final nav = Navigator.of(shell!);
      openMap(shell!);
      await Future<void>.delayed(const Duration(seconds: 4));
      nav.pop();
    }
    cycle();
  }

  Future.delayed(const Duration(seconds: 5), cycle);
}
