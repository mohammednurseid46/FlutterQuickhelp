import 'dart:math' as math;

class PlaceModel {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool? isOpenNow;
  final double? rating;
  final double distanceKm;
  final String? phone;

  const PlaceModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.isOpenNow,
    this.rating,
    this.phone,
  });

  // ── Factory from Overpass API JSON ──────────
  factory PlaceModel.fromJson(
    Map<String, dynamic> json, {
    required double userLat,
    required double userLng,
  }) {
    final tags = (json['tags'] as Map<String, dynamic>?) ?? {};

    // Overpass nodes use 'lat'/'lon', ways use 'center'
    double placeLat;
    double placeLng;
    if (json.containsKey('lat')) {
      placeLat = (json['lat'] as num).toDouble();
      placeLng = (json['lon'] as num).toDouble();
    } else {
      final center = json['center'] as Map<String, dynamic>;
      placeLat = (center['lat'] as num).toDouble();
      placeLng = (center['lon'] as num).toDouble();
    }

    final name = tags['name'] as String? ??
        tags['brand'] as String? ??
        tags['operator'] as String? ??
        'Unnamed Place';

    // Build a readable address from OSM tags
    final parts = <String>[
      if (tags['addr:housenumber'] != null && tags['addr:street'] != null)
        '${tags['addr:housenumber']} ${tags['addr:street']}'
      else if (tags['addr:street'] != null)
        tags['addr:street'] as String,
      if (tags['addr:suburb'] != null) tags['addr:suburb'] as String,
      if (tags['addr:city'] != null) tags['addr:city'] as String,
    ];
    final address = parts.isNotEmpty ? parts.join(', ') : '';

    // Rough open/closed from opening_hours tag
    final hours = tags['opening_hours'] as String?;
    bool? isOpen;
    if (hours != null) {
      final h = hours.toLowerCase();
      isOpen = h == '24/7' || h.contains('open');
    }

    // Phone
    final phone = (tags['phone'] as String?) ??
        (tags['contact:phone'] as String?) ??
        (tags['contact:mobile'] as String?);

    return PlaceModel(
      placeId: json['id'].toString(),
      name: name,
      address: address,
      lat: placeLat,
      lng: placeLng,
      isOpenNow: isOpen,
      phone: phone,
      distanceKm: _haversineKm(userLat, userLng, placeLat, placeLng),
    );
  }

  // ── JSON Cache ──────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'isOpenNow': isOpenNow,
      'rating': rating,
      'phone': phone,
    };
  }

  factory PlaceModel.fromJsonCache(Map<String, dynamic> json, double userLat, double userLng) {
    final pLat = (json['lat'] as num).toDouble();
    final pLng = (json['lng'] as num).toDouble();
    return PlaceModel(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: pLat,
      lng: pLng,
      isOpenNow: json['isOpenNow'] as bool?,
      rating: json['rating'] as double?,
      phone: json['phone'] as String?,
      distanceKm: _haversineKm(userLat, userLng, pLat, pLng),
    );
  }

  // ── Helpers ──────────────────────────────────
  String get distanceText {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Rough walking time at 4.5 km/h
  String get walkTime {
    final minutes = (distanceKm / 4.5 * 60).round();
    if (minutes < 2) return '< 2 min walk';
    return '$minutes min walk';
  }

  /// Rough driving time at 30 km/h (city)
  String get driveTime {
    final minutes = (distanceKm / 30 * 60).round();
    if (minutes < 1) return '< 1 min drive';
    return '$minutes min drive';
  }

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  String get telUrl => 'tel:${phone?.replaceAll(' ', '')}';

  String get googleMapsDirectionsUrl =>
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&destination_place_id=$placeId'
      '&travelmode=driving';

  String get googleMapsUrl =>
      'https://www.google.com/maps/place/?q=place_id:$placeId';

  // ── Haversine distance ───────────────────────
  static double _haversineKm(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
