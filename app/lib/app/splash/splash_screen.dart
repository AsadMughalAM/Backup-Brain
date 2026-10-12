import 'dart:async';

import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/brand_logo.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';

/// First screen: carries on from the Android launch screen (the same mark,
/// same size, same place) while Firebase restores the session, then hands
/// over to Home; the router's redirect takes it on to setup or sign-up.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// Must match the mark in android/.../drawable-*xxxhdpi/splash_mark.png
  /// (112 dp wide, centered), so the hand-over doesn't jump.
  static const markWidth = 112.0;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _wordmarkHeight = 28.0;

  // Long enough for the wordmark to arrive, so a fast session restore
  // doesn't flash the logo for a single frame.
  static const _introLength = Duration(milliseconds: 900);

  // Offline first: if the session can't be read, never hold the user here;
  // Home and the router's redirect cope with an unknown session.
  static const _maxWait = Duration(seconds: 3);
  Timer? _maxWaitTimer;

  late final _intro = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status.isCompleted) _leaveWhenReady();
    });

  late final _wordmark = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.3, 0.75, curve: AppMotion.enter),
  );

  @override
  void initState() {
    super.initState();
    // After the first frame, so reduced motion can be read from the
    // context and a zero-length intro can navigate outside of build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _intro.duration = AppMotion.of(context, _introLength);
      _intro.forward();
      _maxWaitTimer = Timer(_maxWait, _leaveWhenReady);
    });
  }

  void _leaveWhenReady() {
    if (!mounted || !_intro.isCompleted) return;
    final sessionKnown = ref.read(isSignedInProvider) != null;
    final stillWaiting = _maxWaitTimer?.isActive ?? true;
    if (!sessionKnown && stillWaiting) return;
    context.go(Routes.home);
  }

  @override
  void dispose() {
    _maxWaitTimer?.cancel();
    _wordmark.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isSignedInProvider, (_, _) => _leaveWhenReady());
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Semantics(
        label: AppLocalizations.of(context).appTitle,
        excludeSemantics: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Balances the wordmark below, so the mark itself sits at the
              // exact center, where the launch screen drew it.
              const SizedBox(height: AppSpacing.lg + _wordmarkHeight),
              const BrandMark(width: SplashScreen.markWidth),
              const BbGap.lg(),
              FadeTransition(
                opacity: _wordmark,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(_wordmark),
                  child: const BrandWordmark(height: _wordmarkHeight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
