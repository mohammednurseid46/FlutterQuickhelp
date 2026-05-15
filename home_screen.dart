import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/service_type.dart';
import '../theme/app_theme.dart';
import '../widgets/service_button.dart';
import '../widgets/pulse_dot.dart';
import 'results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, ServiceType type) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ResultsScreen(type: type),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),

                // ── Brand row ────────────────────────────
                Animate(
                  effects: [
                    FadeEffect(duration: 600.ms),
                    SlideEffect(
                      begin: const Offset(0, -0.12),
                      end: Offset.zero,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppTheme.pharmacyGradient(),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.glowShadow(AppTheme.pharmacyColor,
                              intensity: 0.38),
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'QuickHelp',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const Spacer(),

                      // Live GPS pulse indicator
                      const Row(
                        children: [
                          PulseDot(color: AppTheme.pharmacyColor, size: 8),
                          SizedBox(width: 6),
                          Text(
                            'GPS On',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Hero text ────────────────────────────
                Animate(
                  delay: 100.ms,
                  effects: [
                    FadeEffect(duration: 600.ms),
                    SlideEffect(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'What do\nyou ',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: -1.6,
                                height: 1.08,
                              ),
                            ),
                            TextSpan(
                              text: 'need?',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.pharmacyColor,
                                letterSpacing: -1.6,
                                height: 1.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'One tap — your 3 closest results, instantly.',
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Service Buttons ──────────────────────
                ServiceButton(
                  type: ServiceType.pharmacy,
                  animationDelay: 200,
                  onTap: () => _navigate(context, ServiceType.pharmacy),
                ),
                const SizedBox(height: 14),
                ServiceButton(
                  type: ServiceType.atm,
                  animationDelay: 330,
                  onTap: () => _navigate(context, ServiceType.atm),
                ),
                const SizedBox(height: 14),
                ServiceButton(
                  type: ServiceType.gas,
                  animationDelay: 460,
                  onTap: () => _navigate(context, ServiceType.gas),
                ),

                const Spacer(),

                // ── Bottom stat pills ────────────────────
                Animate(
                  delay: 700.ms,
                  effects: [FadeEffect(duration: 400.ms)],
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 26),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatPill(icon: Icons.bolt_rounded, label: 'Instant'),
                        SizedBox(width: 10),
                        _StatPill(
                            icon: Icons.wifi_off_rounded,
                            label: 'No Account'),
                        SizedBox(width: 10),
                        _StatPill(icon: Icons.lock_open_rounded, label: 'Free'),
                      ],
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
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
