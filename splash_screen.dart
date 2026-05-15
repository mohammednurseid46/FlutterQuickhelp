import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.background,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo ────────────────────────────────
              Animate(
                effects: [
                  FadeEffect(duration: 600.ms),
                  ScaleEffect(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  ),
                ],
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.pharmacyGradient(),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.glowShadow(AppTheme.pharmacyColor,
                        intensity: 0.45),
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: Colors.black,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── App name ─────────────────────────────
              Animate(
                delay: 300.ms,
                effects: [
                  FadeEffect(duration: 500.ms),
                  SlideEffect(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
                ],
                child: const Text(
                  'QuickHelp',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Tagline ──────────────────────────────
              Animate(
                delay: 500.ms,
                effects: [FadeEffect(duration: 500.ms)],
                child: const Text(
                  'One tap · Three closest · Zero typing',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 64),

              // ── Loading indicator ─────────────────────
              Animate(
                delay: 700.ms,
                effects: [FadeEffect(duration: 400.ms)],
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(
                      AppTheme.pharmacyColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

