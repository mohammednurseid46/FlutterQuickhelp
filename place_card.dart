import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place_model.dart';
import '../models/service_type.dart';
import '../theme/app_theme.dart';
import 'gradient_button.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final ServiceType type;
  final int index;

  const PlaceCard({
    super.key,
    required this.place,
    required this.type,
    required this.index,
  });

  Future<void> _openDirections(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(place.googleMapsDirectionsUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      final fallback = Uri.parse(place.googleMapsUrl);
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callNow(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(place.telUrl);
    await launchUrl(uri);
  }

  Future<void> _openInMaps(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(place.googleMapsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final isFirst = index == 0;

    return Animate(
      delay: Duration(milliseconds: 180 + index * 130),
      effects: [
        FadeEffect(duration: 420.ms),
        SlideEffect(
          begin: const Offset(0, 0.22),
          end: Offset.zero,
          duration: 420.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isFirst ? color.withValues(alpha: 0.45) : AppTheme.border,
            width: isFirst ? 1.8 : 1,
          ),
          boxShadow: isFirst
              ? AppTheme.glowShadow(color, intensity: 0.18)
              : AppTheme.cardShadow(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card header ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank badge (gradient for #1)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isFirst ? type.gradient : null,
                      color: isFirst ? null : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isFirst
                              ? Colors.black
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (place.address.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            place.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (place.hasPhone) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.phone_rounded,
                                  size: 11, color: color),
                              const SizedBox(width: 4),
                              Text(
                                place.phone!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Open / Closed badge
                  if (place.isOpenNow != null)
                    _OpenBadge(isOpen: place.isOpenNow!),
                ],
              ),

              const SizedBox(height: 14),

              // ── Stat chips ──────────────────────────
              Row(
                children: [
                  _Chip(
                    icon: Icons.place_rounded,
                    label: place.distanceText,
                    color: color,
                    highlight: true,
                  ),
                  const SizedBox(width: 7),
                  _Chip(
                    icon: Icons.directions_car_rounded,
                    label: place.driveTime,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  _Chip(
                    icon: Icons.directions_walk_rounded,
                    label: place.walkTime,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 15),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 15),

              // ── Primary action – Get Directions ─────
              GradientButton(
                label: 'Get Directions',
                icon: Icons.navigation_rounded,
                gradient: type.gradient,
                onTap: () => _openDirections(context),
              ),

              const SizedBox(height: 10),

              // ── Secondary row – Call / View Map ─────
              Row(
                children: [
                  // Call now (only if phone exists)
                  if (place.hasPhone) ...[
                    Expanded(
                      child: _OutlineButton(
                        label: 'Call Now',
                        icon: Icons.phone_rounded,
                        color: color,
                        onTap: () => _callNow(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _OutlineButton(
                      label: 'View Map',
                      icon: Icons.map_rounded,
                      color: color,
                      onTap: () => _openInMaps(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Internal widgets ─────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool highlight;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: 0.13)
            : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlight ? color : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpen;
  const _OpenBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final c = isOpen ? AppTheme.openColor : AppTheme.closedColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

