import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/dialogs.dart';
import '../widgets/kawung_pattern.dart';

/// The only way in: continue with Google. Pops `true` once signed in and
/// `false` when the user skips or goes back.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _signIn(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    // A closed account picker leaves no error: nothing to report.
    final error = auth.error;
    if (error != null) {
      final l10n = context.l10n;
      final message = switch (error.code) {
        'GOOGLE_CONFIG' => l10n.authErrorConfig,
        'GOOGLE_TOKEN' || 'GOOGLE_ERROR' => l10n.authErrorFailed,
        _ when error.message.isEmpty => l10n.authErrorFailed,
        _ => l10n.errorMessage(error),
      };
      await showMessageDialog(context, l10n.authFailedTitle, message);
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((a) => a.loading);

    return Scaffold(
      backgroundColor: AppColors.sogan,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.terakota, AppColors.sogan],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: KawungPattern(color: Color(0x1AF6D98A), tileSize: 72),
            ),
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: TextButton(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              child: Text(
                                context.l10n.authLater,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: _Hero()),
                      _SignInCard(
                        loading: loading,
                        onGoogle: () => _signIn(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.pradaLight.withValues(alpha: 0.35),
              ),
            ),
            child: SvgPicture.asset('assets/brand/logo_mark.svg', height: 84),
          ),
          const SizedBox(height: 22),
          const Text.rich(
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
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.authTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({required this.loading, required this.onGoogle});

  final bool loading;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Slides up once when the screen opens.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, 60 * (1 - t)),
        child: Opacity(opacity: t, child: child),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.gading,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.authTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.authSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                _Benefit(
                  icon: Icons.bookmark_rounded,
                  title: l10n.authBenefitSaveTitle,
                  body: l10n.authBenefitSaveBody,
                ),
                _Benefit(
                  icon: Icons.rate_review_rounded,
                  title: l10n.authBenefitReviewTitle,
                  body: l10n.authBenefitReviewBody,
                ),
                _Benefit(
                  icon: Icons.devices_rounded,
                  title: l10n.authBenefitSyncTitle,
                  body: l10n.authBenefitSyncBody,
                ),
                const SizedBox(height: 10),
                GoogleButton(loading: loading, onPressed: onGoogle),
                const SizedBox(height: 14),
                Text(
                  l10n.authPrivacy,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textMuted,
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

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.terakota.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.terakota),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White "Continue with Google" button with the Google mark, following
/// Google's sign-in button guidelines.
class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.loading,
    required this.onPressed,
    this.label,
  });

  final bool loading;
  final VoidCallback onPressed;

  /// Defaults to "Continue with Google" in the app language.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.terakota,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/brand/google_g.svg', height: 22),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label ?? context.l10n.authContinueGoogle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
