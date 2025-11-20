# Backstage Cine - Frontend

Flutter mobile application for Backstage Cine cinema management system.

## Overview

Backstage Cine is a comprehensive cinema management system that provides tools for managing movies, sessions, ticket sales, inventory, and reporting.

## Features

- **Authentication**: Secure employee login system
- **Dashboard**: Real-time overview of cinema operations
- **Point of Sale (POS)**: Ticket and concession sales management
- **Session Management**: Create and manage movie sessions with seat selection
- **Movie Management**: Add, edit, and manage movie catalog
- **Inventory Management**: Track concession inventory and stock levels
- **Room Management**: Configure cinema rooms and seat layouts
- **Reports**: Sales reports, ticket sales analytics, and business insights
- **Profile**: Employee profile and account management

## Tech Stack

- **Framework**: Flutter 3.32.8
- **Language**: Dart 3.8.1
- **State Management**: BLoC (flutter_bloc)
- **HTTP Client**: Dio
- **Dependency Injection**: GetIt
- **Local Storage**: SharedPreferences
- **Architecture**: Clean Architecture with feature-based modules

## Getting Started

### Prerequisites

- Flutter SDK 3.32.8 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Cine-BackStage/backstage_frontend.git
cd backstage_frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# Development mode (connects to local backend)
flutter run

# Production mode (connects to Railway backend)
flutter run --dart-define=ENV=production
```

## Environment Configuration

The app supports two environments:

### Development
- **API URL**: `http://10.0.2.2:3000` (Android Emulator) or `http://localhost:3000` (iOS/Web)
- Automatically detects platform and uses appropriate localhost address

### Production
- **API URL**: `https://backstagebackend-production.up.railway.app`
- Use `--dart-define=ENV=production` flag when building/running

### Custom API URL
You can override the default URL using environment variables:
```bash
flutter run --dart-define=ENV=production --dart-define=API_URL=https://your-custom-api.com
```

## Building for Release

### Android APK
```bash
flutter build apk --release --dart-define=ENV=production
```

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release --dart-define=ENV=production
```

### iOS
```bash
flutter build ios --release --dart-define=ENV=production
```

## Project Structure

```
lib/
├── adapters/               # External adapters (HTTP, Storage, DI)
├── config/                 # App configuration
├── core/                   # Core utilities and constants
├── design_system/          # UI components and theme
├── features/               # Feature modules
│   ├── authentication/
│   ├── dashboard/
│   ├── pos/
│   ├── sessions/
│   ├── movies/
│   ├── inventory/
│   ├── rooms/
│   ├── reports/
│   └── profile/
├── shared/                 # Shared widgets and utilities
└── main.dart              # App entry point
```

## Release Configuration

### Android Signing

The app is configured with release signing. The keystore details are stored in `android/key.properties` (not committed to git).

**Keystore Information:**
- **Location**: `~/backstage-release-key.jks`
- **Alias**: `backstage`
- **Valid until**: April 2053

### Version Management

Version format: `MAJOR.MINOR.PATCH+BUILD`

Current version: **1.0.0+2**

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+2
```

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Test thoroughly on both Android and iOS
4. Commit with clear, descriptive messages
5. Push and create a pull request

## License

Proprietary - Backstage Cine © 2024

## Support

For issues and questions, contact the development team or create an issue in the repository.
