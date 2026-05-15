import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ServiceType {
  pharmacy,
  atm,
  gas;

  String get label {
    switch (this) {
      case ServiceType.pharmacy: return 'Pharmacy';
      case ServiceType.atm:      return 'ATM';
      case ServiceType.gas:      return 'Gas Station';
    }
  }

  String get emoji {
    switch (this) {
      case ServiceType.pharmacy: return '💊';
      case ServiceType.atm:      return '🏧';
      case ServiceType.gas:      return '⛽';
    }
  }

  /// Short punchy subtitle shown on the home button
  String get subtitle {
    switch (this) {
      case ServiceType.pharmacy: return 'Medicine  ·  Healthcare  ·  24/7';
      case ServiceType.atm:      return 'Cash  ·  Withdraw  ·  Banking';
      case ServiceType.gas:      return 'Petrol  ·  Diesel  ·  Top Up';
    }
  }

  /// Hero tag line shown on the results screen header
  String get heroLine {
    switch (this) {
      case ServiceType.pharmacy: return '3 nearest pharmacies found';
      case ServiceType.atm:      return '3 nearest ATMs found';
      case ServiceType.gas:      return '3 nearest gas stations found';
    }
  }

  /// Short action label used in empty / error states
  String get pluralLabel {
    switch (this) {
      case ServiceType.pharmacy: return 'pharmacies';
      case ServiceType.atm:      return 'ATMs';
      case ServiceType.gas:      return 'gas stations';
    }
  }

  /// OpenStreetMap amenity tag
  String get placeType {
    switch (this) {
      case ServiceType.pharmacy: return 'pharmacy';
      case ServiceType.atm:      return 'atm';
      case ServiceType.gas:      return 'fuel';
    }
  }

  Color get color {
    switch (this) {
      case ServiceType.pharmacy: return AppTheme.pharmacyColor;
      case ServiceType.atm:      return AppTheme.atmColor;
      case ServiceType.gas:      return AppTheme.gasColor;
    }
  }

  Color get darkColor {
    switch (this) {
      case ServiceType.pharmacy: return AppTheme.pharmacyDark;
      case ServiceType.atm:      return AppTheme.atmDark;
      case ServiceType.gas:      return AppTheme.gasDark;
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case ServiceType.pharmacy: return AppTheme.pharmacyGradient();
      case ServiceType.atm:      return AppTheme.atmGradient();
      case ServiceType.gas:      return AppTheme.gasGradient();
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.pharmacy: return Icons.local_pharmacy_rounded;
      case ServiceType.atm:      return Icons.atm_rounded;
      case ServiceType.gas:      return Icons.local_gas_station_rounded;
    }
  }
}
