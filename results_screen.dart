import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/place_model.dart';
import '../models/service_type.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../theme/app_theme.dart';
import '../widgets/place_card.dart';
import '../widgets/pulse_dot.dart';

class ResultsScreen extends StatefulWidget {
  final ServiceType type;

  const ResultsScreen({super.key, required this.type});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  _ViewState _state = _ViewState.loading;
  List<PlaceModel> _places = [];
  String _errorMessage = '';
  bool _isPermanentlyDenied = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Wait for the first frame to safely use context for dialogs
    await Future.delayed(Duration.zero);

    if (!mounted) return;
    setState(() {
      _state = _ViewState.loading;
      _errorMessage = '';
      _isOffline = false;
    });

    try {
      final position = await LocationService.getCurrentPosition(context: context);
      final places = await PlacesService.getNearby(
        lat: position.latitude,
        lng: position.longitude,
        type: widget.type,
      );
      if (mounted) {
        setState(() {
          _places = places;
          _state = _ViewState.success;
        });
      }
    } on PlacesOfflineException catch (e) {
      if (mounted) {
        setState(() {
          _places = e.cachedPlaces;
          _state = _ViewState.success;
          _isOffline = true;
        });
      }
    } on LocationException catch (e) {
      if (mounted) {
        setState(() {
          _state = _ViewState.error;
          _errorMessage = e.message;
          _isPermanentlyDenied = e.isPermanentlyDenied;
        });
      }
    } on PlacesException catch (e) {
      if (mounted) {
        setState(() {
          _state = _ViewState.error;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ViewState.error;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.type.color;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────
              _TopBar(type: widget.type, isLoading: _state == _ViewState.loading),

              // ── Content ──────────────────────────────────
              Expanded(
                child: switch (_state) {
                  _ViewState.loading => _LoadingView(color: color),
                  _ViewState.success => _SuccessView(
                      places: _places,
                      type: widget.type,
                      isOffline: _isOffline,
                      onRefresh: _load,
                    ),
                  _ViewState.error => _ErrorView(
                      message: _errorMessage,
                      isPermanentlyDenied: _isPermanentlyDenied,
                      type: widget.type,
                      onRetry: _load,
                      onOpenSettings: () => LocationService.openSettings(
                          app: _isPermanentlyDenied),
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Top bar
// ─────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final ServiceType type;
  final bool isLoading;
  const _TopBar({required this.type, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 0),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearest ${type.label}s',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    if (isLoading) ...[
                      PulseDot(color: color, size: 6),
                      const SizedBox(width: 6),
                      Text(
                        'Locating you…',
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                    ] else
                      const Text(
                        'Top 3 closest to you',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: type.gradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: AppTheme.glowShadow(color, intensity: 0.3),
            ),
            child: Icon(type.icon, color: Colors.black, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Loading state
// ─────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final Color color;
  const _LoadingView({required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
      children: [
        // Status text
        Animate(
          effects: [FadeEffect(duration: 400.ms)],
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Finding nearby services…',
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Shimmer cards
        ...List.generate(
          3,
          (i) => Animate(
            delay: Duration(milliseconds: i * 100),
            effects: [FadeEffect(duration: 300.ms)],
            child: _ShimmerCard(),
          ),
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Shimmer.fromColors(
        baseColor: AppTheme.surfaceElevated,
        highlightColor: AppTheme.borderBright,
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SBox(w: 36, h: 36, r: 11),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SBox(w: double.infinity, h: 16, r: 7),
                        SizedBox(height: 7),
                        _SBox(w: 160, h: 12, r: 6),
                        SizedBox(height: 5),
                        _SBox(w: 110, h: 12, r: 6),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  _SBox(w: 52, h: 24, r: 8),
                ],
              ),
              SizedBox(height: 16),
              Row(children: [
                _SBox(w: 75, h: 26, r: 8),
                SizedBox(width: 7),
                _SBox(w: 85, h: 26, r: 8),
                SizedBox(width: 7),
                _SBox(w: 85, h: 26, r: 8),
              ]),
              SizedBox(height: 16),
              _SBox(w: double.infinity, h: 1, r: 1),
              SizedBox(height: 16),
              _SBox(w: double.infinity, h: 52, r: 14),
              SizedBox(height: 10),
              Row(children: [
                Expanded(child: _SBox(w: double.infinity, h: 44, r: 12)),
                SizedBox(width: 10),
                Expanded(child: _SBox(w: double.infinity, h: 44, r: 12)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SBox extends StatelessWidget {
  final double w, h, r;
  const _SBox({required this.w, required this.h, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Success state
// ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final List<PlaceModel> places;
  final ServiceType type;
  final bool isOffline;
  final Future<void> Function() onRefresh;

  const _SuccessView({
    required this.places,
    required this.type,
    required this.isOffline,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: type.color,
      backgroundColor: AppTheme.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
        itemCount: places.length + (isOffline ? 2 : 1),
        itemBuilder: (context, i) {
          if (isOffline) {
            if (i == 0) return const _OfflineBanner();
            if (i == 1) return _ResultsHeader(type: type, count: places.length);
            return PlaceCard(place: places[i - 2], type: type, index: i - 2);
          } else {
            if (i == 0) return _ResultsHeader(type: type, count: places.length);
            return PlaceCard(place: places[i - 1], type: type, index: i - 1);
          }
        },
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final ServiceType type;
  final int count;
  const _ResultsHeader({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: 400.ms)],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: type.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: type.color),
                  const SizedBox(width: 6),
                  Text(
                    '$count results found',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: type.color,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'Pull to refresh',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "No internet. Showing cached places from your last search.",
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

// ─────────────────────────────────────────────────────────────
//  Error state
// ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isPermanentlyDenied;
  final ServiceType type;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const _ErrorView({
    required this.message,
    required this.isPermanentlyDenied,
    required this.type,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Animate(
            effects: [
              FadeEffect(duration: 400.ms),
              ScaleEffect(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
            ],
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: AppTheme.textSecondary,
                size: 36,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Message
          Animate(
            delay: 100.ms,
            effects: [FadeEffect(duration: 400.ms)],
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.55,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Buttons
          Animate(
            delay: 200.ms,
            effects: [FadeEffect(duration: 400.ms)],
            child: Column(
              children: [
                if (isPermanentlyDenied) ...[
                  SizedBox(
                    width: double.infinity,
                    child: _ErrBtn(
                      label: 'Open App Settings',
                      icon: Icons.settings_rounded,
                      color: type.color,
                      filled: true,
                      onTap: onOpenSettings,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: _ErrBtn(
                    label: 'Try Again',
                    icon: Icons.refresh_rounded,
                    color: AppTheme.textSecondary,
                    filled: false,
                    onTap: onRetry,
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

class _ErrBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ErrBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
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
        height: 52,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: filled ? Colors.black : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.black : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ViewState { loading, success, error }

