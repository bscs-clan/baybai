# BaybAI

An app for transliterating Baybayin script.

## Requirements

Install the following on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio)
- [Git](https://git-scm.com/downloads)
- JDK 17 or newer for Android builds

The Android Gradle wrapper is platform independent and downloads the matching
Gradle version automatically. It is configured for Java 25 and works across
Windows, Linux, and macOS.

## Getting Started

Follow the following steps to setup and run the app:

1. Install dependencies

   ```bash
   flutter pub get
   ```

2. Run the app

   ```bash
   flutter run
   ```

## Production

- Build for Android

  ```bash
  flutter build apk --release --obfuscate --split-debug-info=build/debug-info
  ```

## License

This project is licensed under the terms described in the [LICENSE](./LICENSE) file.
