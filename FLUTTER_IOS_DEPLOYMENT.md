# Flutter iOS Device Deployment Guide

## Problem Summary
Running Flutter app on physical iPhone with `flutter run` showing "no supported devices connected".

## Root Causes & Solutions

### 1. Missing Platform Folders
**Symptom:** Project only has `lib/` and `pubspec.yaml`, no platform-specific folders.

**Solution:**
```bash
flutter create . --project-name <app_name>
```
This generates `ios/`, `android/`, `macos/`, `web/`, `linux/`, `windows/` folders.

### 2. iOS Simulator Not Running
**Symptom:** `flutter devices` doesn't show iOS simulator.

**Solution:** Simulators must be booted first.
```bash
open -a Simulator
# or
xcrun simctl boot "iPhone 17 Pro"
```

### 3. Finding Device ID
```bash
flutter devices
# Output shows: Device Name • DEVICE_ID • platform • OS version
# Use the DEVICE_ID with: flutter run -d <DEVICE_ID>
```

### 4. Code Signing for Physical iPhone

1. Open Xcode workspace:
```bash
open ios/Runner.xcworkspace
```

2. In Xcode:
   - Click **Runner** (blue project icon) in left sidebar
   - Select **Runner** under TARGETS
   - Go to **Signing & Capabilities** tab
   - Check **Automatically manage signing**
   - Click **Add Account** -> sign in with Apple ID
   - Select your **Team** (Personal Team)

3. **Bundle Identifier Error** ("com.example.* cannot be registered"):
   - Change Bundle Identifier to something unique (e.g., `com.yourname.appname`)

### 5. Untrusted Developer Error
App closes immediately on iPhone after installation.

**Solution:** On iPhone:
1. Settings -> General -> VPN & Device Management
2. Tap your developer profile (your Apple ID)
3. Tap **Trust**

### 6. Wireless vs USB Debugging

**Debug mode** requires live connection for hot reload/debugging.
- **USB cable**: Most reliable
- **Wireless**: Can timeout (signal 9 errors)

**Release mode** works better wirelessly:
```bash
flutter run -d <DEVICE_ID> --release
```

### 7. Free Apple Developer Account Limitations
- Apps expire after **7 days**
- Limited to **3 apps** on device
- Must reconnect to reinstall

## Quick Reference Commands
```bash
# Check devices
flutter devices

# Run on specific device
flutter run -d <DEVICE_ID>

# Run in release mode (better for wireless)
flutter run -d <DEVICE_ID> --release

# Clean build
flutter clean && flutter pub get

# List iOS simulators
xcrun simctl list devices available
```
