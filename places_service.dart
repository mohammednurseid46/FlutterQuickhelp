import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/place_model.dart';
import '../models/service_type.dart';

class PlacesException implements Exception {
  final String message;
  const PlacesException(this.message);

  @override
  String toString() => message;
}

class PlacesOfflineException extends PlacesException {
  final List<PlaceModel> cachedPlaces;
  const PlacesOfflineException(super.message, this.cachedPlaces);
}

class PlacesService {
  PlacesService._();

  static const int maxRetries = 3;

  /// Fetches up to [AppConfig.maxResults] nearby places using Overpass API.
  /// Implements Exponential Backoff retry, fallback mirrors, and SharedPreferences offline caching.
  static Future<List<PlaceModel>> getNearby({
    required double lat,
    required double lng,
    required ServiceType type,
  }) async {
    final query = '''
[out:json][timeout:15];
(
  node["amenity"="${type.placeType}"](around:${AppConfig.searchRadiusMeters},$lat,$lng);
  way["amenity"="${type.placeType}"](around:${AppConfig.searchRadiusMeters},$lat,$lng);
);
out body center qt;
''';

    final body = 'data=${Uri.encodeComponent(query)}';
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    int attempt = 1;
    http.Response? response;

    while (attempt <= maxRetries) {
      try {
        // Try Primary
        response = await http
            .post(Uri.parse(AppConfig.overpassUrl), headers: headers, body: body)
            .timeout(AppConfig.networkTimeout);
      } catch (_) {
        // Try Fallback Mirror
        try {
          response = await http
              .post(Uri.parse(AppConfig.overpassFallbackUrl), headers: headers, body: body)
              .timeout(AppConfig.networkTimeout);
        } catch (_) {
          response = null;
        }
      }

      if (response != null && response.statusCode == 200) break; // Success!

      // Exponential Backoff Wait (1s, 2s, 4s...)
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      }
      attempt++;
    }

    if (response == null || response.statusCode != 200) {
      return _handleOfflineOrError(type, lat, lng);
    }

    // --- Parsing Success ---
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>? ?? [];

    if (elements.isEmpty) {
      throw PlacesException('No ${type.pluralLabel} found nearby.\nTry moving to a different area.');
    }

    final places = elements.map((j) {
      try {
        return PlaceModel.fromJson(j as Map<String, dynamic>, userLat: lat, userLng: lng);
      } catch (_) {
        return null;
      }
    }).whereType<PlaceModel>().toList();

    if (places.isEmpty) {
      throw PlacesException('No ${type.pluralLabel} could be loaded nearby.');
    }

    places.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final result = places.take(AppConfig.maxResults).toList();

    // Cache the result for offline fallback
    await _cachePlaces(type, result);

    return result;
  }

  // --- Offline Caching Logic ---
  static const String _cacheKeyPrefix = 'quickhelp_places_';

  static Future<void> _cachePlaces(ServiceType type, List<PlaceModel> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = places.map((p) => p.toJson()).toList();
      await prefs.setString('$_cacheKeyPrefix${type.name}', jsonEncode(jsonList));
    } catch (_) {
      // Silently fail if cache fails
    }
  }

  static Future<List<PlaceModel>> _handleOfflineOrError(ServiceType type, double userLat, double userLng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('$_cacheKeyPrefix${type.name}');
      if (cachedString != null) {
        final decoded = jsonDecode(cachedString) as List<dynamic>;
        final cachedPlaces = decoded
            .map((j) => PlaceModel.fromJsonCache(j as Map<String, dynamic>, userLat, userLng))
            .toList();
        if (cachedPlaces.isNotEmpty) {
          cachedPlaces.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          throw PlacesOfflineException('Network failed. Showing offline cached data.', cachedPlaces);
        }
      }
    } catch (e) {
      if (e is PlacesOfflineException) rethrow; // Pass up the offline exception
    }
    
    // Total failure + no cache
    throw const PlacesException('Network unavailable to fetch data.\nPlease try again later.');
  }
}
