import 'package:flutter/material.dart';
import '../main.dart';
import 'main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _progress;
  late final Animation<double> _progressPulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _scale = Tween(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Progress bar fills from 0 to 1 with an ease that slows near the end
    _progress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    // Subtle shimmer pulse overlay on top of the fill
    _progressPulse = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScaffold(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A0A3A), AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 52),
                    _buildProgressBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 80,
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 42),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
        children: [
          TextSpan(text: 'AUTO', style: TextStyle(color: AppColors.white)),
          TextSpan(text: 'TESTER', style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'AI-Powered Playwright Generation',
      style: TextStyle(
        color: AppColors.muted,
        fontSize: 13,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final fill = _progress.value;
        final shimmerPos = _progressPulse.value;

        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 120,
                height: 3,
                child: Stack(
                  children: [
                    // Track
                    Container(color: AppColors.faint),

                    // Fill with gradient
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fill,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFFA78BFA),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Shimmer sweep on top of the fill
                    if (fill > 0.05)
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fill,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: shimmerPos.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.35),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Percentage counter
            Text(
              '${(fill * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                fontFamily: 'Courier',
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}