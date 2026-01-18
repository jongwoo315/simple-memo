# Suggested Commands for Development

## Running the App
```bash
# Run on connected device or simulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Run on Chrome (web)
flutter run -d chrome

# Run on macOS
flutter run -d macos

# Run on iOS simulator
flutter run -d ios
```

## Building
```bash
# Build Android APK
flutter build apk

# Build iOS
flutter build ios

# Build macOS
flutter build macos

# Build web
flutter build web
```

## Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Fix linting issues automatically
dart fix --apply
```

## Dependency Management
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

## Utility Commands (Darwin/macOS)
```bash
# List files
ls -la

# Find files
find . -name "*.dart"

# Search in files
grep -r "pattern" lib/

# Git operations
git status
git add .
git commit -m "메시지"
git push
```

## Clean & Reset
```bash
# Clean build artifacts
flutter clean

# After clean, get dependencies again
flutter pub get
```
