# 🌍 Location Logger: Premium Location Tracking App

**Location Logger** is a high-performance, premium Flutter application designed for continuous location tracking. It seamlessly captures your journey in the background, calculates distances, and provides real-time metrics through a sophisticated Material 3 interface.

## ✨ Features

- **🚀 Persistent Background Tracking**: High-accuracy location logging using a dedicated background isolate.
- **📊 Real-time Dashboard**: Live updates for Latitude, Longitude, Points Logged, and Total Distance.
- **💎 Premium UI/UX**: A modern, Material 3 design featuring:
  - Custom Indigo & Slate color palette.
  - Animated pulse indicators for active tracking.
  - Responsive grid-based metric dashboard.
  - Clean, professional typography and layout.
- **📜 Journey Logs**:
  - **Grouped Journeys**: Automatically groups location points into distinct "journeys" (tracked from Start to Stop).
  - **Session Analytics**: View start/end times, total points, and precise distance for every specific journey.
  - **Drill-down Details**: Tap on any journey to view the complete history of latitude and longitude coordinates captured during that trip.
- **🛡️ Robust Permissions**: Graceful handling of location permissions and system service status.
- **🗺️ Navigation**: Seamless screen transitions powered by `GoRouter`.

## 🏗️ Technical Architecture

The app is built using **Clean Architecture** principles to ensure maintainability and testability:

- **Domain Layer**: Contains business entities, repository interfaces, and use cases.
- **Data Layer**: Handles data persistence via `SQFLite`, data models, and repository implementations.
- **Core Layer**: Shared utilities, constants, theme configurations, and routing.
- **Presentation Layer**: UI implementation using `Flutter Riverpod` for reactive state management.

## 🛠️ Tech Stack

| Category | Tools |
|----------|-------|
| **State Management** | `flutter_riverpod` |
| **Navigation** | `go_router` |
| **Location** | `geolocator` |
| **Background** | `flutter_background_service` |
| **Database** | `sqflite` |
| **Notifications** | `flutter_local_notifications` |
| **Utilities** | `intl`, `uuid`, `path_provider` |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Physical device (recommended for testing background features)

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/location_logger_app.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Platform Configuration**:
   - **Android**: Ensure `AndroidManifest.xml` has the required background location and foreground service permissions.
   - **iOS**: 
     - Open `ios/Runner.xcworkspace` in Xcode.
     - Enable **Location updates** under **Background Modes** in the 'Signing & Capabilities' tab.
     - Ensure `Info.plist` has the necessary usage descriptions for Location (Always and When In Use).
     - Run `pod install` in the `ios` directory before building.

### 🛠️ Troubleshooting (iOS)
If you encounter `Module not found` errors in Xcode:
1. Ensure you are opening the `.xcworkspace` file, not the `.xcodeproj`.
2. Disable Swift Package Manager if prompted (this project is optimized for CocoaPods).
3. Run `flutter clean` and then `flutter run`.

4. **Run the application**:
   ```bash
   flutter run
   ```

## 📝 License

This project is open-source and available under the MIT License.
