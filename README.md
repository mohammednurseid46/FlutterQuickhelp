# ⚡ QuickHelp

> **One tap. Three closest services. Zero typing.**

A lightning-fast Flutter app that finds the 3 nearest **Pharmacies**, **ATMs**, and **Gas Stations** — instantly, with one tap.

---

## 📁 Project Structure

```
quickhelp/
├── lib/
│   ├── main.dart                  ← App entry point
│   ├── config.dart                ← 🔑 API key goes here
│   ├── theme/
│   │   └── app_theme.dart         ← Colors, fonts, dark theme
│   ├── models/
│   │   ├── service_type.dart      ← Pharmacy / ATM / Gas enum
│   │   └── place_model.dart       ← Place data + distance math
│   ├── services/
│   │   ├── location_service.dart  ← GPS + permissions
│   │   └── places_service.dart    ← Google Places API calls
│   ├── screens/
│   │   ├── home_screen.dart       ← 3-button main screen
│   │   └── results_screen.dart    ← Results + loading + error
│   └── widgets/
│       ├── service_button.dart    ← Animated tap button
│       └── place_card.dart        ← Result card with actions
├── android/app/src/main/
│   └── AndroidManifest.xml        ← Location + internet permissions
├── ios/Runner/
│   └── Info.plist                 ← iOS location permissions
└── pubspec.yaml                   ← Dependencies
```

---

## 🚀 Setup (5 steps)

### 1. Install Flutter
Follow: https://docs.flutter.dev/get-started/install

### 2. Get a Google API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Enable these APIs:
   - **Places API** (for nearby search)
   - **Maps SDK for Android** (for directions link)
   - **Maps SDK for iOS** (for directions link)
4. Create an API key under **Credentials**
5. (Optional but recommended) Restrict the key to your app's bundle ID

### 3. Add your API Key

Open `lib/config.dart` and replace:
```dart
static const String googleApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
```
with your actual key.

### 4. Install dependencies

```bash
cd quickhelp
flutter pub get
```

### 5. Run the app

```bash
# Android
flutter run

# iOS (requires Xcode on macOS)
flutter run -d ios
```

---

## ⚙️ Configuration

In `lib/config.dart`:

| Setting | Default | Description |
|---|---|---|
| `googleApiKey` | (your key) | Google Places API key |
| `searchRadiusMeters` | 5000 | Search radius (meters) |
| `maxResults` | 3 | Number of results shown |

---

## 📱 Features

- **One-tap search** — tap Pharmacy, ATM, or Gas to instantly search
- **Real GPS** — uses device location (high accuracy)
- **Live data** — pulls from Google Places (always up to date)
- **Distance** — shows km, walking time, driving time
- **Open/Closed** — shows current opening status
- **Get Directions** — opens Google Maps with route pre-drawn
- **Shimmer loading** — smooth skeleton cards while fetching
- **Error handling** — clear messages + retry + settings shortcut
- **Dark mode** — premium 2026-style dark UI
- **Haptic feedback** — tactile response on every tap
- **Animations** — smooth fade + slide transitions

---

## 🔧 Dependencies

| Package | Purpose |
|---|---|
| `geolocator` | GPS location |
| `permission_handler` | Runtime permissions |
| `http` | API calls |
| `url_launcher` | Open Maps / calls |
| `google_fonts` | Inter font |
| `flutter_animate` | Animations |
| `shimmer` | Loading skeletons |

---

## 🏗️ Build for Release

### Android (APK)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle for Play Store)
```bash
flutter build appbundle --release
```

### iOS (requires macOS + Xcode)
```bash
flutter build ios --release
```

---

## 💡 Customization Tips

**Add more service types** → Add entries to `ServiceType` enum in `lib/models/service_type.dart`

**Change search radius** → Update `searchRadiusMeters` in `lib/config.dart`

**Change accent colors** → Edit `AppTheme` in `lib/theme/app_theme.dart`

**Show more results** → Update `maxResults` in `lib/config.dart`

---

*Built with Flutter · Powered by Google Places API*
