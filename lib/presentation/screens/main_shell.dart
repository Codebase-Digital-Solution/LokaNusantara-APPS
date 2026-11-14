import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../core/notifications/agenda_reminders.dart';
import '../navigation/root_navigator.dart';
import '../providers/collections_provider.dart';
import '../providers/location_provider.dart';
import '../providers/shell_controller.dart';
import '../providers/trail_provider.dart';
import '../theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../navigation/map_navigation.dart';
import 'agenda_screen.dart';
import 'collections_screens.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Bottom-navigation shell: Beranda, Tersimpan, Agenda and Profil, with a
/// raised map button in the centre that opens the map as its own page.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locations = context.read<LocationProvider>();
      locations.fetchCategories();
      locations.fetchLocations(limit: 100);
      context.read<CollectionsProvider>().load();
      context.read<AgendaProvider>().load();
      context.read<TrailProvider>().load();
      _openReminderThatLaunchedApp();
    });
  }

  /// When the app was started by tapping an agenda reminder, show the
  /// reminders page right away.
  Future<void> _openReminderThatLaunchedApp() async {
    final launched = await context
        .read<ReminderScheduler>()
        .launchedFromReminder();
    if (launched && mounted) openNotificationsFromReminder();
  }

  @override
  Widget build(BuildContext context) {
    final tab = context.select<ShellController, ShellTab>((s) => s.tab);
    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        children: const [
          HomeScreen(),
          SavedScreen(),
          AgendaScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        current: tab,
        onSelect: context.read<ShellController>().goTo,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.current, required this.onSelect});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 64 + bottom,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: context.l10n.shellHome,
            active: current == ShellTab.home,
            onTap: () => onSelect(ShellTab.home),
          ),
          _NavItem(
            icon: Icons.bookmark_border,
            activeIcon: Icons.bookmark_rounded,
            label: context.l10n.shellSaved,
            active: current == ShellTab.saved,
            onTap: () => onSelect(ShellTab.saved),
          ),
          Expanded(child: _MapButton(onTap: () => openMap(context))),
          _NavItem(
            icon: Icons.event_note_outlined,
            activeIcon: Icons.event_note_rounded,
            label: context.l10n.shellAgenda,
            active: current == ShellTab.agenda,
            onTap: () => onSelect(ShellTab.agenda),
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: context.l10n.shellProfile,
            active: current == ShellTab.profile,
            onTap: () => onSelect(ShellTab.profile),
          ),
        ],
      ),
    );
  }
}

/// Icon-only tab. [label] is not drawn; it is announced by screen readers
/// and shown as a tooltip on long press.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.terakota : AppColors.textMuted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: Tooltip(
          message: label,
          child: InkResponse(
            onTap: onTap,
            radius: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.15 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    active ? activeIcon : icon,
                    color: color,
                    size: 26,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(top: 6),
                  width: active ? 18 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.prada,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised circular map button that overlaps the top edge of the bar and
/// opens the map page.
class _MapButton extends StatelessWidget {
  const _MapButton({required this.onTap});

  final VoidCallback onTap;

  static const _size = 62.0;

  /// How far the circle rises above the bar's top edge.
  static const _lift = 22.0;

  @override
  Widget build(BuildContext context) {
    // A Stack keeps the layout inside the bar's height; the circle is drawn
    // above the edge with clipBehavior none instead of growing the bar.
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -_lift,
          child: Semantics(
            button: true,
            label: context.l10n.shellOpenMap,
            child: Tooltip(
              message: context.l10n.shellMap,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.terakota, AppColors.sogan],
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.terakota.withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
