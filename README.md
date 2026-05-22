# 🍅 Schedulr — Personal Workflow App

A beautifully crafted Flutter productivity app for personal scheduling, deep work, and daily habit tracking. Built with a dark violet aesthetic and a full feature set.

---

## ✨ Features

| Feature | Description |
|---|---|
| **Dashboard** | Today's task overview, completion rate, quick stats |
| **Pomodoro Timer** | Animated ring timer, work/break phases, session tracking, task linking |
| **Task Manager** | Create, categorise, prioritise & schedule tasks with notifications |
| **Alarm Clock** | Set multiple alarms with custom ringtones from device storage |
| **Progress Tracker** | 7-day bar & line charts, streaks, weekly summary |
| **Notifications** | Task reminders, daily briefing, pomodoro alerts, streak nudges |
| **Settings** | Personalise name, notification times, clear data |

---

## 🛠 Tech Stack

- **Flutter 3.x** — cross-platform mobile (Android & iOS)
- **Provider** — state management
- **Hive** — local NoSQL persistence
- **flutter_local_notifications** — scheduled & instant push notifications
- **just_audio + file_picker** — custom alarm ringtone playback
- **fl_chart** — interactive progress charts
- **Google Fonts (Space Grotesk)** — distinctive typography
- **wakelock_plus** — keeps screen on during focus sessions

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.10.0` ([install](https://flutter.dev/docs/get-started/install))
- Dart SDK `>=3.0.0`
- Android Studio / Xcode for device testing
- Java 17+ for Android builds

### Clone & Run

```bash
git clone https://github.com/YOUR_USERNAME/schedulr.git
cd personal-workflow-app

# Install dependencies
flutter pub get

# Generate Hive adapters (already pre-generated)
# dart run build_runner build --delete-conflicting-outputs

# Generate launcher icons
flutter pub run flutter_launcher_icons

# Run on connected device
flutter run

# Run tests
flutter test
```

### Build APK (Debug)

```bash
flutter build apk --debug --split-per-abi
# Output: build/app/outputs/flutter-apk/
```

### Build APK (Release)

```bash
# First, set up your keystore — see android/key.properties.example
flutter build apk --release --split-per-abi
```

---

## 🔧 GitHub Actions CI/CD

The `.github/workflows/build.yml` pipeline runs automatically on every push:

| Job | Trigger | What it does |
|---|---|---|
| `analyze_and_test` | Every push/PR | Lint, format check, unit tests + coverage |
| `build_android_debug` | Every push | Builds debug APKs (split per ABI) |
| `build_android_release` | `main` branch only | Builds signed release APK + AAB |
| `build_ios` | `main` branch only | Builds iOS archive (no codesign) |
| `create_release` | Tagged commits | Publishes GitHub Release with APK |

### Required GitHub Secrets (for release builds)

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded `.jks` keystore file |
| `KEY_ALIAS` | Key alias in the keystore |
| `KEY_PASSWORD` | Key password |
| `STORE_PASSWORD` | Keystore password |

---

## 📁 Project Structure

```
personal-workflow-app/
├── .github/
│   └── workflows/
│       └── build.yml              # CI/CD pipeline
├── android/
│   ├── app/
│   │   ├── build.gradle           # App-level Gradle config
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── java/com/hammad/schedulr/
│   │       │   └── MainActivity.kt
│   │       └── res/
│   │           ├── drawable/      # Splash screen
│   │           ├── mipmap-*/      # Launcher icons (all densities)
│   │           └── values/        # Themes & styles
│   ├── build.gradle               # Root Gradle config
│   ├── gradle.properties
│   └── settings.gradle
├── ios/
│   ├── Runner/
│   │   ├── Assets.xcassets/       # App icons (all iOS sizes)
│   │   └── Info.plist             # iOS config + permissions
│   └── Podfile
├── assets/
│   ├── icons/
│   │   ├── app_icon.png           # 1024x1024 master icon
│   │   └── app_icon_foreground.png # Adaptive icon foreground
│   └── sounds/                    # (Place custom sounds here)
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/
│   │   ├── alarm_model.dart       # Alarm Hive model
│   │   ├── task_model.dart        # Task Hive model
│   │   └── pomodoro_session_model.dart
│   ├── providers/
│   │   ├── alarm_provider.dart
│   │   ├── pomodoro_provider.dart
│   │   ├── progress_provider.dart
│   │   └── task_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart       # Root nav shell
│   │   ├── dashboard_screen.dart  # Today overview
│   │   ├── pomodoro_screen.dart   # Animated timer
│   │   ├── tasks_screen.dart      # Task CRUD
│   │   ├── alarm_screen.dart      # Alarm management
│   │   ├── progress_screen.dart   # Charts & streaks
│   │   ├── settings_screen.dart
│   │   └── notification_settings_screen.dart
│   ├── services/
│   │   └── notification_service.dart
│   ├── utils/
│   │   └── app_theme.dart         # Design tokens & theme
│   └── widgets/
│       ├── task_tile.dart
│       ├── section_header.dart
│       ├── glass_card.dart
│       └── animated_gradient_bg.dart
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 🎨 Design System

| Token | Value | Usage |
|---|---|---|
| `bg` | `#0A0A0F` | App background |
| `surface` | `#12121A` | Cards, nav bar |
| `accent` | `#7C3AED` | Primary violet |
| `pomodoroWork` | `#EF4444` | Focus timer |
| `pomodoroBreak` | `#10B981` | Break timer |
| `success` | `#10B981` | Completed tasks |
| `warning` | `#F59E0B` | Medium priority |
| `danger` | `#EF4444` | High priority / delete |

Font: **Space Grotesk** (Google Fonts)

---

## 📝 Custom Ringtone Setup

1. Open the **Alarms** tab
2. Tap **Add Alarm**
3. Tap the 🎵 **ringtone picker** row
4. Select any `.mp3`, `.m4a`, or `.aac` file from device storage
5. The app stores the file path and plays it at alarm time

---

## 🧪 Running Tests

```bash
flutter test                    # All tests
flutter test --coverage         # With coverage report
genhtml coverage/lcov.info -o coverage/html  # HTML report
```

---

## 📄 License

MIT © 2024 Hammad
