import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/permission_sheet.dart';

class LocationService {
  LocationService._();

  /// Returns the current position, optionally showing a rationale UI if needed.
  static Future<Position> getCurrentPosition({BuildContext? context}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please enable GPS in your device settings.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (context != null && context.mounted) {
        final allow = await PermissionBottomSheet.show(context);
        if (allow && context.mounted) {
          permission = await Geolocator.requestPermission();
        }
      } else {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission denied. QuickHelp needs your location to find nearby services.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission permanently denied. Please enable it in your app settings.',
        isPermanentlyDenied: true,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException('Could not determine your location. Try again.');
    }
  }

  static Future<void> openSettings({bool app = false}) async {
    if (app) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }
}

class LocationException implements Exception {
  final String message;
  final bool isPermanentlyDenied;

  const LocationException(this.message, {this.isPermanentlyDenied = false});

  @override
  String toString() => message;
}
