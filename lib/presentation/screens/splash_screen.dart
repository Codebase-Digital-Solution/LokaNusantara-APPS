import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../widgets/kawung_pattern.dart';

/// Animated intro: logo bounce, title slide-up, tagline and pulsing dots,
/// then a fade out. Calls [onFinish] once the animation completes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Timeline (ms): logo 0-700, title 700-1050, tagline 1050-1350,
  // hold until 2250, fade out 2250-2650.
  static const _totalMs = 2650.0;

  late final AnimationController _main = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _totalMs.toInt()),
  );
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  Animation<double> _interval(
    double startMs,
    double endMs, [
    Curve curve = Curves.easeOut,
  ]) => CurvedAnimation(
    parent: _main,
    curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
  );

  late final _logoScale = Tween(
    begin: 0.3,
    end: 1.0,
  ).animate(_interval(0, 700, Curves.elasticOut));
  late final _logoOpacity = _interval(0, 400);
  late final _title = _interval(700, 1050);
  late final _tagline = _interval(1050, 1350);
  late final _fadeOut = Tween(
    begin: 1.0,
    end: 0.0,
  ).animate(_interval(2250, 2650));

  @override
  void initState() {
    super.initState();
    _main.forward().whenComplete(() {
      if (mounted) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _main.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOut,
      // Material gives the texts a proper default style; SizedBox.expand makes
      // the splash fill the screen instead of shrinking to its content.
      child: Material(
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.terakota, AppColors.sogan],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: KawungPattern(color: Color(0x1AF6D98A), tileSize: 72),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: SvgPicture.asset(
                          'assets/brand/logo_mark.svg',
                          height: 132,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _title,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_title),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Loka',
                                style: TextStyle(color: AppColors.pradaLight),
                              ),
                              TextSpan(
                                text: 'Nusantara',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _tagline,
                      child: Text(
                        context.l10n.splashTagline,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 80,
                  child: FadeTransition(
                    opacity: _tagline,
                    child: AnimatedBuilder(
                      animation: _dots,
                      builder: (context, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [for (var i = 0; i < 3; i++) _dot(i)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(int index) {
    // Each dot pulses for 600ms, staggered by 200ms.
    final t = (_dots.value * 1000 - index * 200) % 1000;
    final phase = t < 300 ? t / 300 : (t < 600 ? 1 - (t - 300) / 300 : 0.0);
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pradaLight.withValues(alpha: 0.3 + 0.7 * phase),
      ),
    );
  }
}
