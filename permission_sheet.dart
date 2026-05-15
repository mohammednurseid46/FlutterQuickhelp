import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'gradient_button.dart';

class PermissionBottomSheet extends StatelessWidget {
  const PermissionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppTheme.glowShadow(AppTheme.pharmacyColor, intensity: 0.1),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.pharmacyGradient(),
                boxShadow: AppTheme.glowShadow(AppTheme.pharmacyColor, intensity: 0.2),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 40,
                color: Colors.white,
              ),
            ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            Text(
              "We need your location",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            Text(
              "QuickHelp finds the nearest pharmacy, ATM, or gas station instantly. We strictly use your location to find nearby services, without saving or tracking you.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            
            GradientButton(
              label: "Allow Location Access",
              icon: Icons.check_circle_outline,
              gradient: AppTheme.pharmacyGradient(),
              onTap: () {
                Navigator.of(context).pop(true);
              },
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Not Now",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  /// Helper to easily show this bottom sheet
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => const PermissionBottomSheet(),
    );
    return result ?? false;
  }
}
