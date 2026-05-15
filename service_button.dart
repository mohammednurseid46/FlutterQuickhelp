import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/service_type.dart';
import '../theme/app_theme.dart';

class ServiceButton extends StatefulWidget {
  final ServiceType type;
  final VoidCallback onTap;
  final int animationDelay;

  const ServiceButton({
    super.key,
    required this.type,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<ServiceButton> createState() => _ServiceButtonState();
}

class _ServiceButtonState extends State<ServiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.955).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    HapticFeedback.mediumImpact();
    await _pressCtrl.forward();
    await _pressCtrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.type.color;
    final gradient = widget.type.gradient;

    return Animate(
      delay: Duration(milliseconds: widget.animationDelay),
      effects: [
        FadeEffect(duration: 520.ms),
        SlideEffect(
          begin: const Offset(0, 0.18),
          end: Offset.zero,
          duration: 520.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 116,
              decoration: BoxDecoration(
                // Gradient fill on hover, solid surface otherwise
                gradient: _hovered ? gradient : null,
                color: _hovered ? null : AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _hovered
                      ? Colors.transparent
                      : color.withValues(alpha: 0.28),
                  width: 1.5,
                ),
                boxShadow: AppTheme.glowShadow(
                  color,
                  intensity: _hovered ? 0.35 : 0.14,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // ── Ambient colour blob (top-left) ─────
                    Positioned(
                      top: -24,
                      left: -24,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: _hovered ? 0.18 : 0.07),
                        ),
                      ),
                    ),

                    // ── Row content ────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          // Icon Container
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _hovered
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : color.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Icon(
                              widget.type.icon,
                              color: _hovered ? Colors.white : color,
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 18),

                          // Text section
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.type.label,
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    color: _hovered
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.type.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _hovered
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow badge
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _hovered
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _hovered ? Colors.white : color,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

