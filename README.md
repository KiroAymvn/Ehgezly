# Hotel Management Flutter App

![App Home Mockup](file:///C:/Users/Kero/.gemini/antigravity/brain/2cba84c3-0283-4abc-9d9d-6b47fa770aa1/app_home_mockup_1775652398358.png)

## 📖 Overview
A modern, **offline‑first** hotel management mobile application built with **Flutter**. It showcases a clean architecture that separates UI, business logic, and data layers, using **BLoC (Cubit)** for state management and **Hive** for local persistence. The app supports full CRUD operations for rooms, guests, reservations, and employees, and provides a polished UI with vibrant colors, glass‑morphism effects, and subtle micro‑animations.

## ✨ Key Features
- **BLoC (Cubit) Architecture** – Decoupled UI and business logic, easy testing.
- **Hive Persistence** – Fast, type‑safe local storage with generated TypeAdapters.
- **Responsive UI** – Adaptive grid layouts, dark mode support, and smooth animations.
- **CRUD Operations** – Manage rooms, guests, reservations, and employees.
- **Advanced Filtering** – Real‑time search, price range, view‑type, and capacity filters.
- **Reservation Conflict Detection** – Prevent double‑booking with date‑conflict logic.
- **Modular Codebase** – Feature‑based folders, reusable widgets, and clear naming.
- **Comprehensive Tests** – Unit and widget tests for core cubits and services.

## 🏗️ Architecture Overview
```
lib/
├─ models/               # Hive‑annotated data classes (Room, Guest, Reservation, Employee)
├─ data/
│   ├─ local/            # Hive initialization & sample data
│   └─ repositories/     # Pure data‑access logic (RoomRepository, etc.)
├─ services/             # Facade (HotelService) coordinating repositories
├─ features/
│   ├─ rooms/
│   │   ├─ cubit/        # RoomCubit + RoomState
│   │   └─ dialogs/      # Add/Edit Room dialogs
│   ├─ guests/ …
│   └─ reservations/ …
├─ screens/              # UI screens (customer & manager flows)
│   ├─ customer/         # Customer UI (grid, details, booking)
│   └─ manager/          # Manager dashboard & admin screens
└─ main.dart             # App entry – Hive init, MultiBlocProvider
```

- **Models** are annotated with `@HiveType` and `@HiveField` and have generated adapters (`*.g.dart`).
- **Repositories** contain pure Dart logic without any Flutter dependencies.
- **Service Layer** (`HotelService`) acts as a façade, exposing high‑level methods used by the UI.
- **Cubits** expose streams of immutable state objects (`RoomState`, `GuestState`, …) consumed via `BlocBuilder`/`BlocListener`.
- **UI** is built from small, reusable widgets (e.g., `RoomGridCard`, `ActiveFiltersBar`).

## 🚀 Getting Started
### Prerequisites
- **Flutter SDK** ≥ 3.22.0
- **Dart** ≥ 3.3.0
- **Java JDK 17** (required for Android builds)
- **Android Studio** or **VS Code** with Flutter extensions

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/hotel-management-flutter.git
cd hotel-management-flutter

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Running the App
```bash
# Run on a connected device or emulator
flutter run
```

### Building for Release
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

## 🧪 Testing
```bash
# Unit & widget tests
flutter test
```
The test suite covers cubit logic, repository methods, and UI widget interactions.

## 📸 Screenshots & UI Mockups
- **Home Screen** – Grid of rooms with image, price, and availability badge (see mockup above).
- **Room Details** – Detailed view with amenities, booking button, and status indicator.
- **Manager Dashboard** – Stats cards, filter sheet, and CRUD dialogs.

## 🤝 Contributing
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/awesome-feature`).
3. Ensure code follows the existing architecture and passes `flutter analyze`.
4. Write tests for new functionality.
5. Submit a Pull Request with a clear description.

## 📄 License
This project is licensed under the **MIT License** – see the `LICENSE` file for details.

---
*Crafted with ❤️ by the Antigravity AI assistant – a modern, production‑ready Flutter codebase.*
