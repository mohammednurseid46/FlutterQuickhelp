/// ─────────────────────────────────────────────
///  QuickHelp – App Configuration
///  Uses OpenStreetMap Overpass API
///  ✅ 100% Free — No API key required
///  ✅ No credit card — No billing ever
/// ─────────────────────────────────────────────
class AppConfig {
  AppConfig._();

  /// Search radius in meters (7 km)
  static const int searchRadiusMeters = 7000;

  /// Number of closest results to display
  static const int maxResults = 3;

  /// Primary Overpass API endpoint
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Fallback mirror (used when primary times out)
  static const String overpassFallbackUrl = 'https://overpass.kumi.systems/api/interpreter';

  /// Request timeout for location
  static const Duration locationTimeout = Duration(seconds: 12);

  /// Request timeout for Overpass
  static const Duration networkTimeout = Duration(seconds: 22);
}
