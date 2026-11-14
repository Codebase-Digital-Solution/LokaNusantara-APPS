import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/notifications/agenda_reminders.dart';
import '../di/service_locator.dart';
import '../l10n/l10n.dart';
import '../domain/repositories/onboarding_repository.dart';
import 'navigation/root_navigator.dart';
import 'providers/agenda_provider.dart';
import 'providers/agenda_reminders_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/saved_plans_provider.dart';
import 'providers/shell_controller.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';
import '../domain/usecases/location_usecases.dart';
import '../domain/usecases/planner_usecases.dart';

class LokaNusantaraApp extends StatefulWidget {
  const LokaNusantaraApp({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  State<LokaNusantaraApp> createState() => _LokaNusantaraAppState();
}

class _LokaNusantaraAppState extends State<LokaNusantaraApp>
    with WidgetsBindingObserver {
  late final LocaleProvider _locale = widget.locator.createLocaleProvider()
    ..load();

  ServiceLocator get locator => widget.locator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locale.dispose();
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) => _locale.deviceLocaleChanged();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _locale),
        Provider.value(value: locator.directions),
        Provider<OnboardingRepository>.value(value: locator.onboarding),
        Provider<ReminderScheduler>.value(value: locator.reminderScheduler),
        Provider<GetLocationByIdUseCase>.value(value: locator.locationById),
        Provider<CreateTripPlanUseCase>.value(value: locator.createTripPlan),
        ChangeNotifierProvider(create: (_) => locator.createAuthProvider()),
        ChangeNotifierProvider(create: (_) => locator.createLocationProvider()),
        ChangeNotifierProvider(create: (_) => locator.createReviewProvider()),
        // Saved places follow the signed-in account.
        ChangeNotifierProxyProvider<AuthProvider, CollectionsProvider>(
          create: (_) => locator.createCollectionsProvider(),
          update: (_, auth, collections) =>
              collections!..setUser(auth.user?.id),
        ),
        // Saved visit plans also follow the signed-in account.
        ChangeNotifierProxyProvider<AuthProvider, SavedPlansProvider>(
          create: (_) => locator.createSavedPlansProvider(),
          update: (_, auth, plans) => plans!..setUser(auth.user?.id),
        ),
        ChangeNotifierProvider(create: (_) => locator.createAgendaProvider()),
        // Re-plans agenda reminders whenever the agenda or the app language
        // changes. Not lazy,
        // so reminders are kept up to date from app start.
        ChangeNotifierProxyProvider2<
          AgendaProvider,
          LocaleProvider,
          AgendaRemindersProvider
        >(
          lazy: false,
          create: (_) => locator.createAgendaRemindersProvider()..load(),
          update: (_, agenda, locale, reminders) => reminders!
            ..setLanguage(locale.locale.languageCode)
            ..onEvents(agenda.events, loaded: agenda.loaded),
        ),
        ChangeNotifierProvider(create: (_) => locator.createTrailProvider()),
        ChangeNotifierProvider(
          create: (_) => locator.createTanyaLokaProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ShellController()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) => MaterialApp(
          navigatorKey: rootNavigatorKey,
          onGenerateTitle: (context) => context.l10n.appTitle,
          locale: locale.locale,
          supportedLocales: appLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: AppColors.theme(),
          // Ignore the system font size setting so layouts stay as designed.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
          home: const _RootGate(),
        ),
      ),
    );
  }
}

/// Splash, then onboarding on first launch, then the main shell.
class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  late final Future<bool> _startup = _prepare();
  bool _splashDone = false;
  bool? _onboardingDone;

  Future<bool> _prepare() async {
    final results = await Future.wait<Object?>([
      context.read<AuthProvider>().checkAuth(),
      context.read<OnboardingRepository>().isCompleted(),
    ]);
    return results[1]! as bool;
  }

  Future<void> _finishOnboarding() async {
    // Enter the app first; persisting the flag must never block it.
    setState(() => _onboardingDone = true);
    await context.read<OnboardingRepository>().setCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _startup,
      builder: (context, snapshot) {
        final ready = snapshot.connectionState == ConnectionState.done;
        final onboardingDone = _onboardingDone ?? snapshot.data ?? false;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: onboardingDone
                    ? const MainShell(key: ValueKey('shell'))
                    : OnboardingScreen(
                        key: const ValueKey('onboarding'),
                        onDone: _finishOnboarding,
                      ),
              ),
            if (!ready || !_splashDone)
              SplashScreen(onFinish: () => setState(() => _splashDone = true)),
          ],
        );
      },
    );
  }
}
