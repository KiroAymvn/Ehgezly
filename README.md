# Hotel Management Application

A modern, offline-first Flutter application for comprehensive hotel management. This project demonstrates clean architecture principles, robust state management, and efficient local data persistence.

## Features

- **Guest Management**: Registration, profile updates, and history tracking.
- **Room Management**: Real-time room status, categorisation (Nile View, Suite, Regular), and capacity handling.
- **Reservation System**: Booking creation, date-conflict validation, status tracking (Confirmed, Checked-in, Checked-out, Cancelled), and billing.
- **Employee Directory**: Department-based filtering and contact management.
- **Offline-First Storage**: All data is securely stored locally using high-performance Hive database.
- **Advanced Filtering for Customers**: Customers can search and filter rooms by views, capacities, prices, and availability dates.

## Architecture

The project follows a **Feature-First Clean Architecture** approach:

- **Data Layer (Hive)**: Relies on `hive_flutter` for lightning-fast, synchronous local storage using JSON-encoded strings or typed boxes for `Room`, `Guest`, `Reservation`, and `Employee`.
- **Repository Interface**: Abstractions that isolate the UI and business logic from the underlying storage mechanism.
- **Service Layer**: Coordinate repositories and enforce complex domain rules (e.g., date-overlap checks for room bookings).
- **Presentation Layer (BLoC/Cubit)**: Extracts state from the UI using `flutter_bloc`. Separates discrete states (Initial, Loaded, Error) ensuring deterministic UI rendering.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit)
- **Local Storage**: [Hive](https://docs.hivedb.dev/)
- **Date Formatting**: [intl](https://pub.dev/packages/intl)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable recommended)
- **Java Development Kit (JDK 11 or higher)** — *Note: Android builds require at least JVM 11.*

### Installation

1. Clean the project and fetch packages:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Run code generation for Hive TypeAdapters (if required by annotations):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Troubleshooting

### Android Build Error: "Dependency requires at least JVM runtime version 11"

If you encounter this error, your system or IDE is currently using Java 8 to build the Android project. Gradle 8.0+ requires **Java 11 or 17**.

**Fix in Android Studio:**
1. Go to **Settings/Preferences** > **Build, Execution, Deployment** > **Build Tools** > **Gradle**.
2. Under **Gradle JDK**, select a JDK version that is `11` or `17` (e.g., `jbr-17`).

**Fix via Environment Variable (Terminal):**
Update your `JAVA_HOME` environment variable to point to your JDK 11 or 17 installation path.
