import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../config/supabase_config.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

/// One controller drives the whole sequence (no spinner, no timers), so the
/// splash is a single smooth, deterministic timeline:
///   0.00–0.35  logo pops in      0.20–0.65  rings ripple out
///   0.35–0.70  name letters rise 0.60–0.85  tagline fades in
///   0.00–1.00  thin progress bar fills, then fade to Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _name = 'സഹായി';

  late final AnimationController _c;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _c =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 4000),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _goNext();
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // Decode the logo before the first frame of the animation so the
    // intro never stutters.
    precacheImage(const AssetImage('assets/logo.png'), context).whenComplete(
      () {
        if (mounted) _c.forward();
      },
    );
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, anim, secondary) =>
            supabase.auth.currentSession != null
            ? const DashboardScreen()
            : const LoginScreen(),
        transitionsBuilder: (_, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _interval(
    double a,
    double b, [
    Curve curve = Curves.easeOut,
  ]) => CurvedAnimation(
    parent: _c,
    curve: Interval(a, b, curve: curve),
  );

  @override
  Widget build(BuildContext context) {
    final logoScale = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(_interval(0.0, 0.35, Curves.easeOutBack));
    final logoFade = _interval(0.0, 0.2);
    final tagFade = _interval(0.60, 0.85);
    final tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(_interval(0.60, 0.85, Curves.easeOutCubic));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE3F3DF),
                  Color(0xFFF6FAF5),
                  Color(0xFFFFF4E5),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          // Soft decorative blobs (static, drift slightly with the timeline).
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(painter: _BlobPainter(_c.value)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                // The ripples need 300px, but only the logo should take up
                // layout space so the name sits close underneath it.
                SizedBox(
                  height: 220,
                  child: OverflowBox(
                    maxHeight: 300,
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _c,
                              builder: (_, _) => CustomPaint(
                                size: const Size(300, 300),
                                painter: _RipplePainter(_c.value),
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: logoFade,
                            child: ScaleTransition(
                              scale: logoScale,
                              child: Container(
                                width: 184,
                                height: 184,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.leaf.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                // The logo PNG has an opaque white background, so
                                // clip it to the circle or its square corners show.
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _AnimatedName(controller: _c, text: _name),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: tagFade,
                  child: SlideTransition(
                    position: tagSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        S.of(context, 'tagline'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 96),
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: Curves.easeInOut.transform(_c.value),
                        minHeight: 4,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.leaf,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The name with each letter rising and fading in one after another.
/// Split by grapheme so Malayalam vowel signs stay joined to their consonant.
class _AnimatedName extends StatelessWidget {
  final AnimationController controller;
  final String text;
  const _AnimatedName({required this.controller, required this.text});

  @override
  Widget build(BuildContext context) {
    final letters = text.characters.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (i) {
        final start = 0.35 + i * 0.045;
        final anim = CurvedAnimation(
          parent: controller,
          curve: Interval(
            start,
            math.min(start + 0.2, 1),
            curve: Curves.easeOutCubic,
          ),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (_, child) => Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - anim.value)),
              child: child,
            ),
          ),
          child: Text(
            letters[i],
            style: const TextStyle(
              fontFamily: AppTheme.headingFont,
              fontSize: 50,
              fontWeight: FontWeight.w900,
              color: AppColors.forest,
              letterSpacing: 1,
            ),
          ),
        );
      }),
    );
  }
}

/// Two soft rings expanding out from the logo, once.
class _RipplePainter extends CustomPainter {
  final double t;
  _RipplePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 2; i++) {
      final start = 0.2 + i * 0.12;
      final p = ((t - start) / 0.45).clamp(0.0, 1.0);
      if (p == 0) continue;
      final eased = Curves.easeOutCubic.transform(p);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.leaf.withValues(alpha: 0.35 * (1 - p));
      canvas.drawCircle(center, 92 + 56 * eased, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.t != t;
}

/// Large translucent circles in the background that drift gently.
class _BlobPainter extends CustomPainter {
  final double t;
  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = AppColors.leaf.withValues(alpha: 0.08);
    final orange = Paint()..color = AppColors.roof.withValues(alpha: 0.10);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * (0.08 + 0.02 * t)),
      size.width * 0.38,
      green,
    );
    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * (0.92 - 0.02 * t)),
      size.width * 0.42,
      orange,
    );
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}
