import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../../l10n/l10n.dart';
import '../navigation/location_navigation.dart';
import '../navigation/map_navigation.dart';
import '../providers/agenda_reminders_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/dialogs.dart';
import '../widgets/kawung_pattern.dart';
import '../widgets/language_picker.dart';
import 'collections_screens.dart';
import 'sign_in_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void _openRecent(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const RecentScreen()));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.gading,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(
            name: user?.name ?? l10n.profileGuestName,
            email: user?.email ?? l10n.profileGuestEmail,
            avatarUrl: user?.avatarUrl,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (user == null)
                  _AuthPrompt(onLogin: () => showAuthFlow(context)),
                _MenuGroup(
                  children: [
                    const _ReminderSwitch(),
                    _MenuTile(
                      icon: Icons.translate_rounded,
                      label: l10n.language,
                      value:
                          languageNames[context
                              .watch<LocaleProvider>()
                              .locale
                              .languageCode],
                      onTap: () => showLanguagePicker(context),
                    ),
                    _MenuTile(
                      icon: Icons.history_rounded,
                      label: l10n.profileRecent,
                      onTap: () => _openRecent(context),
                    ),
                    _MenuTile(
                      icon: Icons.map_outlined,
                      label: l10n.profileOpenMap,
                      onTap: () => openMap(context),
                    ),
                    _MenuTile(
                      icon: Icons.slideshow_outlined,
                      label: l10n.profileShowIntro,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (routeContext) => OnboardingScreen(
                            onDone: () => Navigator.of(routeContext).pop(),
                          ),
                        ),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.info_outline,
                      label: l10n.profileAbout,
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'LokaNusantara',
                        applicationVersion: '1.0.0',
                        applicationIcon: SvgPicture.asset(
                          'assets/brand/logo_mark.svg',
                          height: 48,
                        ),
                        children: [Text(l10n.profileAboutBody)],
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.restart_alt,
                      label: l10n.profileIntroOnLaunch,
                      onTap: () async {
                        await context.read<OnboardingRepository>().setCompleted(
                          false,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(l10n.profileIntroOnLaunchDone),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                if (user != null)
                  _MenuGroup(
                    children: [
                      _MenuTile(
                        icon: Icons.logout,
                        label: l10n.profileSignOut,
                        color: const Color(0xFFC0262D),
                        onTap: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: l10n.profileSignOut,
                            message: l10n.profileSignOutMessage,
                            confirmLabel: l10n.profileSignOutConfirm,
                            destructive: true,
                          );
                          if (ok) await auth.logout();
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Round profile picture: the Google photo when there is one, otherwise
/// (or while it loads, or if it fails) the user's initials.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.initials});

  final String? url;
  final String initials;

  static const _size = 68.0;

  /// Google photo URLs end with a size such as "=s96-c"; ask for one sharp
  /// enough for this avatar on high-density screens.
  static String _sized(String url) =>
      url.replaceFirst(RegExp(r'=s\d+(-c)?$'), '=s256-c');

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.sogan,
        ),
      ),
    );
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.prada,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: url == null
            ? fallback
            : Image.network(
                _sized(url!),
                fit: BoxFit.cover,
                width: _size,
                height: _size,
                semanticLabel: context.l10n.profilePhoto,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.terakota, AppColors.sogan],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              child: KawungPattern(color: Color(0x1AF6D98A), tileSize: 56),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 52),
              child: Row(
                children: [
                  _Avatar(
                    url: avatarUrl,
                    initials: initials.isEmpty ? '?' : initials,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthPrompt extends StatelessWidget {
  const _AuthPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.profileAuthTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.profileAuthBody,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          GoogleButton(loading: false, onPressed: onLogin),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Material (not a decorated Container) so ListTile ink splashes show.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, indent: 56, color: AppColors.border),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// On/off switch for agenda reminders, with a hint when the phone blocks
/// notifications for the app.
class _ReminderSwitch extends StatelessWidget {
  const _ReminderSwitch();

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<AgendaRemindersProvider>();
    final blocked = reminders.enabled && reminders.permissionGranted == false;
    return SwitchListTile(
      secondary: const Icon(
        Icons.notifications_active_outlined,
        color: AppColors.terakota,
      ),
      title: Text(
        context.l10n.profileReminders,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        blocked
            ? context.l10n.profileRemindersBlocked
            : context.l10n.profileRemindersHint,
        style: TextStyle(
          fontSize: 12,
          color: blocked ? const Color(0xFFB4630C) : AppColors.textSecondary,
        ),
      ),
      value: reminders.enabled,
      activeThumbColor: AppColors.terakota,
      onChanged: reminders.setEnabled,
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.value,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  /// Current setting shown before the chevron.
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color == AppColors.textPrimary ? AppColors.terakota : color,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
