# Code Style and Conventions

## Linting
- Uses `flutter_lints: ^3.0.0` via `analysis_options.yaml`
- Standard Flutter recommended lints

## Dart/Flutter Conventions
- **Language**: Korean comments are acceptable (as shown in the codebase)
- **Naming**: 
  - Classes: PascalCase (e.g., `HomeScreen`, `StorageService`)
  - Methods/Variables: camelCase (e.g., `_loadMemos`, `_currentColorValue`)
  - Private members: prefixed with `_` (e.g., `_memos`, `_controller`)
  - Constants: camelCase or SCREAMING_SNAKE_CASE for static const
- **File naming**: snake_case (e.g., `home_screen.dart`, `storage_service.dart`)

## Widget Patterns
- `const` constructor where possible
- `super.key` parameter for keys
- Private state classes prefixed with `_` (e.g., `_HomeScreenState`)
- StatefulWidget for complex UI with state
- StatelessWidget for simple, immutable UI

## Data Model Patterns
- Immutable classes with `final` fields
- `required` keyword for constructor parameters
- JSON serialization via `toJson()` and `fromJson()` factory methods

## State Management
- Local state with `StatefulWidget` and `setState`
- `TextEditingController` for text input
- `FocusNode` for focus management

## Constants
- Static const for colors and fixed values
- Color values as hex integers (e.g., `0xFF5B8BA0`)
- Magic numbers extracted to named constants (e.g., `_maxLength = 30`)

## Import Organization
- Dart core imports first
- Package imports second
- Relative imports last
