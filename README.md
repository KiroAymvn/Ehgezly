# 🏨 Grand Hotel Management System

A **Flutter** application for managing hotel operations — rooms, guests, reservations, and employees. Built with **Provider** for state management and **SharedPreferences** for local data persistence.

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots (Screens)](#-screens-overview)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [How the App Works](#-how-the-app-works)
- [Data Flow](#-data-flow)
- [Key Files Explained](#-key-files-explained)
- [Common Tasks for Developers](#-common-tasks-for-developers)
- [Dependencies](#-dependencies)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Features

### Guest Portal (Customer Side)
- Browse all available rooms with images, prices, and amenities
- Advanced filtering by view type, capacity, price range, and availability
- Search rooms by number, type, or capacity
- Book a room by selecting dates and entering guest information
- Check room availability for specific date ranges
- View detailed room information in a bottom sheet

### Manager Dashboard
- Dashboard with stats: employees, rooms, guests, reservations, revenue
- **Rooms**: Add, edit, delete rooms; toggle availability
- **Guests**: Add, edit, delete guests; search by name/phone/email
- **Reservations**: Full CRUD, filter by status, sort by multiple criteria, generate bills, export summaries
- **Employees**: Add, edit, delete; filter by department

---

## 🏗 Architecture

The app uses a **layered architecture**:

```
┌──────────────────────────────┐
│        SCREENS (UI)          │  ← What the user sees (widgets)
├──────────────────────────────┤
│       PROVIDERS (State)      │  ← State management (ChangeNotifier + Provider)
├──────────────────────────────┤
│     HOTEL SERVICE (Logic)    │  ← Singleton facade — all business logic
├──────────────────────────────┤
│     REPOSITORIES (Data)      │  ← CRUD operations on in-memory lists
├──────────────────────────────┤
│   LOCAL STORAGE (Persist)    │  ← SharedPreferences (JSON read/write)
└──────────────────────────────┘
```

**Key design decisions:**
- **Singleton `HotelService`** — one shared instance across the entire app; providers and screens never access repositories directly.
- **Provider** — each data type has its own `ChangeNotifierProvider` so the UI rebuilds automatically when data changes.
- **SharedPreferences** — all data is stored locally as JSON strings; no backend server is needed.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, providers & routes
│
├── core/
│   ├── constants/app_constants.dart   # App-wide constants
│   ├── theme/app_theme.dart           # Material theme configuration
│   └── utils/
│       ├── date_formatter.dart        # Date formatting helper
│       └── status_helpers.dart        # Status colors & icons
│
├── models/                            # Plain Dart data classes
│   ├── room.dart                      # Room model (id, number, viewType, etc.)
│   ├── guest.dart                     # Guest model (id, name, phone, birthday)
│   ├── reservation.dart               # Reservation model (dates, status)
│   └── employee.dart                  # Employee model (name, department)
│
├── data/
│   ├── local/
│   │   ├── local_storage_service.dart # SharedPreferences read/write
│   │   └── sample_data.dart           # Seed data for first launch
│   └── repositories/                  # CRUD operations on in-memory lists
│       ├── room_repository.dart
│       ├── guest_repository.dart
│       ├── reservation_repository.dart
│       └── employee_repository.dart
│
├── services/
│   └── hotel_service.dart             # ⭐ Singleton facade (core of the app)
│
├── providers/                         # State management (ChangeNotifier)
│   ├── room_provider.dart
│   ├── guest_provider.dart
│   ├── reservation_provider.dart
│   └── employee_provider.dart
│
├── screens/
│   ├── login_screen.dart              # Start screen (Guest Portal / Manager)
│   ├── customer/                      # Guest-facing screens
│   │   ├── customer_home_screen.dart  # Room browsing with filters
│   │   ├── room_details_sheet.dart    # Room detail bottom sheet
│   │   ├── date_range_dialog.dart     # Date picker with availability check
│   │   ├── add_guest_dialog.dart      # Guest info form for booking
│   │   └── room_calender_screen.dart  # Room booking calendar
│   └── manager/                       # Manager-facing screens
│       ├── manager_home_screen.dart   # Dashboard with stats
│       ├── all_rooms_screen.dart      # Room list management
│       ├── all_guests_screen.dart     # Guest list management
│       ├── all_reservations_screen.dart # Reservation management
│       ├── all_employees_screen.dart  # Employee management
│       └── ... (dialogs for add/edit)
│
├── features/manager/rooms/dialogs/    # Room CRUD dialogs
│   ├── add_room_dialog.dart
│   └── edit_room_dialog.dart
│
└── widgets/                           # Reusable widgets
    ├── stat_card.dart
    ├── room_card.dart
    ├── reservation_card.dart
    ├── filter_chip.dart
    └── activity_item.dart

assets/
└── room.jpg                           # Default room image

test/
└── widget_test.dart                   # Smoke test for login screen
```

---

## 🚀 Getting Started

### Prerequisites

| Tool    | Version          | Check             |
|---------|------------------|--------------------|
| Flutter | 3.10+ (Dart 3.x) | `flutter --version` |
| Android Studio or VS Code | Latest | —                 |

### Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd database_project

# 2. Install dependencies
flutter pub get

# 3. Run the app (on a connected device or emulator)
flutter run

# 4. Run tests
flutter test

# 5. Analyze code for issues
flutter analyze
```

### First Launch
On first launch, the app automatically seeds **5 sample rooms** and **4 sample employees** so you can start exploring immediately. This data is persisted in SharedPreferences.

---

## 🔄 How the App Works

### App Startup Flow

```
main() → HotelService().initialize() → Load data from SharedPreferences
       → If empty, seed sample data
       → runApp() with MultiProvider (4 providers)
       → LoginScreen is shown
```

### User Flows

#### Guest Booking a Room
1. User taps **"Guest Portal"** on the login screen
2. `CustomerHomeScreen` shows all available rooms in a grid
3. User can search, filter by view type / capacity / price range
4. User taps **"Book Now"** on a room card
5. `DateRangeDialog` opens — user picks check-in and check-out dates
6. User can optionally click **"Check Availability"**
7. `AddGuestDialog` opens — user enters name, phone, email, birthday
8. `ReservationProvider.reserve()` is called → `HotelService.addReservation()`
9. Data is saved to SharedPreferences and UI rebuilds

#### Manager Managing Rooms
1. User taps **"Manager Dashboard"** on the login screen
2. Dashboard shows stats for all entities
3. User navigates to **"All Rooms"**
4. Can add/edit/delete rooms, toggle availability
5. Changes go through `RoomProvider` → `HotelService` → `RoomRepository`

---

## 📊 Data Flow

```
UI (Screen/Widget)
    │
    ▼
Provider (ChangeNotifier)    ← UI calls methods here
    │
    ▼
HotelService (Singleton)    ← Business logic & validation
    │
    ▼
Repository                  ← CRUD on in-memory List<T>
    │
    ▼
LocalStorageService          ← SharedPreferences (JSON persistence)
```

**Example: Adding a reservation**
```dart
// 1. Screen calls:
context.read<ReservationProvider>().reserve(guestId, roomId, checkIn, checkOut);

// 2. Provider calls:
await _service.addReservation(guestId: ..., roomId: ..., checkIn: ..., checkOut: ...);

// 3. HotelService validates (room exists? guest exists? room available?) then:
_reservations_.add(newId: ..., guestId: ..., roomId: ..., ...);

// 4. HotelService saves:
await saveAllData();  // → LocalStorageService → SharedPreferences
```

---

## 📝 Key Files Explained

| File | What it does |
|------|-------------|
| `main.dart` | Entry point — initializes `HotelService`, sets up 4 providers and all routes |
| `hotel_service.dart` | **The brain of the app** — singleton that coordinates all repositories and handles persistence |
| `local_storage_service.dart` | All SharedPreferences read/write in one place |
| `sample_data.dart` | Seed data (5 rooms, 4 employees) loaded on first launch |
| `room_provider.dart` | State management for rooms — wraps `HotelService` room methods |
| `customer_home_screen.dart` | Main guest screen — room grid with search & advanced filters |
| `manager_home_screen.dart` | Manager dashboard with stat cards, quick actions, recent activity |
| `all_reservations_screen.dart` | Full reservation management with filter, sort, edit, bill, delete |

---

## 🛠 Common Tasks for Developers

### Adding a New Room Field
1. Add the field to `models/room.dart` (class property, constructor, `toJson`, `fromJson`)
2. Update `data/repositories/room_repository.dart` (the `add` and `update` methods)
3. Update `services/hotel_service.dart` (`addRoom` and `updateRoom` methods)
4. Update `providers/room_provider.dart` (`addRoom` and `updateRoom` methods)
5. Update the UI: `add_room_dialog.dart`, `edit_room_dialog.dart`, and display screens

### Adding a New Screen
1. Create the screen widget in `screens/` (customer or manager folder)
2. Add a route in `main.dart` → `routes: { ... }`
3. Navigate to it: `Navigator.pushNamed(context, '/yourRoute')`

### Changing the Theme
Edit `lib/core/theme/app_theme.dart` — the `AppTheme.light` getter.

### Resetting All Data
The debug screen (`/debug` route) or calling `HotelService().clearAllData()` will reset to seed data.

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management (ChangeNotifier pattern) |
| `shared_preferences` | Local data persistence (JSON in key-value store) |
| `intl` | Date formatting (`DateFormat`) |
| `cupertino_icons` | iOS-style icons |

---

## 🔧 Troubleshooting

| Problem | Solution |
|---------|---------|
| App crashes on launch | Run `flutter clean && flutter pub get` then try again |
| Data not showing | The app seeds data on first launch. If corrupted, go to Debug screen or clear app data |
| Build fails | Ensure Flutter SDK ≥ 3.10. Run `flutter doctor` to diagnose |
| Provider not found error | Make sure you import from `providers/room_provider.dart` (single underscore), not any duplicate file |

---

## 📄 License

This project is for educational purposes.
