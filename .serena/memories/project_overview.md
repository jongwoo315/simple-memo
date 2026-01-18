# Simple Memo - Project Overview

## Purpose
간단한 메모 앱 (Simple Memo App) - A minimalist Flutter-based memo application for quick note-taking.

## Tech Stack
- **Framework**: Flutter (Dart SDK >=3.0.0 <4.0.0)
- **State Management**: StatefulWidget with setState
- **Local Storage**: shared_preferences for memo persistence
- **ID Generation**: uuid package for unique memo IDs
- **UI**: Material Design 3

## Key Dependencies
- `flutter` - Core SDK
- `shared_preferences: ^2.2.2` - Local key-value storage
- `uuid: ^4.2.1` - UUID generation

## Dev Dependencies
- `flutter_test` - Testing framework
- `flutter_lints: ^3.0.0` - Linting rules

## Codebase Structure
```
lib/
├── main.dart              # App entry point, MaterialApp configuration
├── models/
│   └── memo.dart          # Memo data model with JSON serialization
├── screens/
│   └── home_screen.dart   # Main UI with circular memo layout
└── services/
    └── storage_service.dart  # SharedPreferences wrapper for memo persistence
test/
└── widget_test.dart       # Widget tests
```

## Key Features
- Create memos with random dusty-tone colors
- Delete memos via long press
- Maximum 30 characters per memo
- Circular/flow layout with pipe separators
- Persistent storage using SharedPreferences
- Cream/yellowish background (0xFFFAF6E9)

## Architecture
- Simple MVC-like pattern
- `Memo` model with JSON serialization
- `StorageService` for data persistence
- Single-screen app with `HomeScreen`
