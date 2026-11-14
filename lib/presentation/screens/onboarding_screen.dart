import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_style.dart';
import '../../l10n/l10n.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_icon.dart';
import '../widgets/kawung_pattern.dart';
import '../widgets/language_picker.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.colors,
    required this.center,
    required this.orbit,
  });

  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;

  /// Background gradient; blended with the neighbouring page while swiping.
  final List<Color> colors;
  final Widget center;
  final List<Widget> orbit;
}

Widget _categoryOrbit(String name) {
  final style = categoryStyleOf(name);
  return CategoryIcon(style, size: 24, color: style.color);
}

Widget _iconOrbit(IconData icon, Color color) =>
    Icon(icon, size: 24, color: color);

final _pages = <_OnboardingPage>[
  _OnboardingPage(
    title: (l10n) => l10n.onbWelcomeTitle,
    body: (l10n) => l10n.onbWelcomeBody,
    colors: const [AppColors.terakota, AppColors.sogan],
    center: SvgPicture.asset('assets/brand/logo_mark.svg', height: 108),
    orbit: [
      for (final c in [
        'tradisi',
        'pura',
        'masjid',
        'gereja',
        'vihara',
        'kuliner',
      ])
        _categoryOrbit(c),
    ],
  ),
  _OnboardingPage(
    title: (l10n) => l10n.onbTraditionTitle,
    body: (l10n) => l10n.onbTraditionBody,
    colors: const [Color(0xFF8E3B5E), Color(0xFF341328)],
    center: CategoryIcon(categoryStyleOf('tradisi'), size: 84),
    orbit: [
      for (final c in ['pura', 'masjid', 'gereja', 'vihara', 'klenteng'])
        _categoryOrbit(c),
    ],
  ),
  _OnboardingPage(
    title: (l10n) => l10n.onbCulinaryTitle,
    body: (l10n) => l10n.onbCulinaryBody,
    colors: const [Color(0xFF6B8E23), Color(0xFF25330C)],
    center: CategoryIcon(categoryStyleOf('kuliner'), size: 84),
    orbit: [
      for (final icon in [
        Icons.rice_bowl,
        Icons.soup_kitchen,
        Icons.local_cafe,
        Icons.ramen_dining,
        Icons.set_meal,
      ])
        _iconOrbit(icon, const Color(0xFF6B8E23)),
    ],
  ),
  _OnboardingPage(
    title: (l10n) => l10n.onbRouteTitle,
    body: (l10n) => l10n.onbRouteBody,
    colors: const [AppColors.nila, Color(0xFF111E33)],
    center: const Icon(Icons.map_rounded, size: 84, color: Colors.white),
    orbit: [
      for (final icon in [
        Icons.bookmark,
        Icons.directions,
        Icons.history,
        Icons.star_rounded,
        Icons.near_me,
      ])
        _iconOrbit(icon, AppColors.nila),
    ],
  ),
];

/// First-run introduction with orbiting icons, parallax text, a background
/// that blends between pages and an expanding page indicator.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbit.dispose();
    _float.dispose();
    _intro.dispose();
    super.dispose();
  }

  bool get _isLast => _page.round() == _pages.length - 1;

  void _next() {
    if (_isLast) {
      widget.onDone();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<Color> _backgroundColors() {
    final index = _page.floor().clamp(0, _pages.length - 1);
    final next = (index + 1).clamp(0, _pages.length - 1);
    final t = (_page - index).clamp(0.0, 1.0);
    return [
      Color.lerp(_pages[index].colors[0], _pages[next].colors[0], t)!,
      Color.lerp(_pages[index].colors[1], _pages[next].colors[1], t)!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgroundColors();
    final current = _page.round().clamp(0, _pages.length - 1);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bg,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.translate(
                // The motif drifts slowly as the user swipes.
                offset: Offset(-_page * 40, 0),
                child: const KawungPattern(
                  color: Color(0x14FFFFFF),
                  tileSize: 72,
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
                child: Column(
                  children: [
                    SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          const _LanguageButton(),
                          const Spacer(),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isLast ? 0 : 1,
                            child: TextButton(
                              onPressed: _isLast ? null : widget.onDone,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                context.l10n.onbSkip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        itemBuilder: (context, i) => _PageContent(
                          page: _pages[i],
                          offset: i - _page,
                          orbit: _orbit,
                          float: _float,
                        ),
                      ),
                    ),
                    _Indicator(count: _pages.length, page: _page),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: _NextButton(
                        last: _isLast,
                        color: _pages[current].colors[0],
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.offset,
    required this.orbit,
    required this.float,
  });

  final _OnboardingPage page;

  /// Distance from the centred page: 0 when fully visible, +-1 off screen.
  final double offset;
  final Animation<double> orbit;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    final distance = offset.abs().clamp(0.0, 1.0);
    final visibility = 1 - distance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Opacity(
                opacity: visibility,
                child: Transform.scale(
                  scale: 0.7 + 0.3 * visibility,
                  child: Transform.rotate(
                    angle: offset * 0.4,
                    child: _OrbitIllustration(
                      center: page.center,
                      items: page.orbit,
                      orbit: orbit,
                      float: float,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Title and body move at different speeds for a parallax feel.
          Transform.translate(
            offset: Offset(offset * 140, 0),
            child: Opacity(
              opacity: visibility,
              child: Text(
                page.title(context.l10n),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Transform.translate(
            offset: Offset(offset * 260, 0),
            child: Opacity(
              opacity: visibility,
              child: Text(
                page.body(context.l10n),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _OrbitIllustration extends StatelessWidget {
  const _OrbitIllustration({
    required this.center,
    required this.items,
    required this.orbit,
    required this.float,
  });

  final Widget center;
  final List<Widget> items;
  final Animation<double> orbit;
  final Animation<double> float;

  static const _size = 300.0;
  static const _radius = 118.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: AnimatedBuilder(
        animation: Listenable.merge([orbit, float]),
        builder: (context, _) {
          final spin = orbit.value * 2 * math.pi;
          final bob = math.sin(float.value * math.pi) * 8;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Dashed ring turning against the orbit.
              Transform.rotate(
                angle: -spin,
                child: const CustomPaint(
                  size: Size.square(_radius * 2),
                  painter: _DashedRingPainter(),
                ),
              ),
              // Soft glow behind the centrepiece.
              Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pradaLight.withValues(
                        alpha: 0.18 + 0.12 * float.value,
                      ),
                      blurRadius: 48,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
              ),
              Transform.translate(offset: Offset(0, -bob), child: center),
              for (var i = 0; i < items.length; i++) _orbitItem(i, spin, bob),
            ],
          );
        },
      ),
    );
  }

  Widget _orbitItem(int i, double spin, double bob) {
    final angle = spin + i * 2 * math.pi / items.length;
    // Each satellite bobs slightly out of phase with the centre.
    final wobble = math.sin(angle * 2) * 6 + bob * 0.3;
    return Transform.translate(
      offset: Offset(
        math.cos(angle) * (_radius + wobble),
        math.sin(angle) * (_radius + wobble),
      ),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: items[i],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    const dashes = 48;
    const sweep = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) => false;
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.count, required this.page});

  final int count;
  final double page;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              // Width grows smoothly as the page approaches this dot.
              final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
              return Container(
                width: 8 + 20 * t,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.35),
                    AppColors.pradaLight,
                    t,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.last,
    required this.color,
    required this.onPressed,
  });

  final bool last;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Grows from a round arrow button into a full-width "start" button.
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: last ? constraints.maxWidth : 64,
          height: 64,
          child: _buttonBody(context),
        ),
      ),
    );
  }

  Widget _buttonBody(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black38,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: last
                ? Text(
                    context.l10n.onbStart,
                    key: const ValueKey('start'),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_rounded,
                    key: const ValueKey('next'),
                    color: color,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Lets first-time visitors switch language before reading the intro.
/// Hidden when no [LocaleProvider] is above (bare widget tests).
class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider?>(context);
    if (locale == null) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => showLanguagePicker(context),
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      icon: const Icon(Icons.translate_rounded, size: 18),
      label: Text(
        languageNames[locale.locale.languageCode] ?? '',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
