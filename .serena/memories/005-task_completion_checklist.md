# Task Completion Checklist

## Before Marking a Task Complete

### 1. Code Quality
- [ ] Run `flutter analyze` - ensure no errors or warnings
- [ ] Run `dart format .` - ensure code is properly formatted
- [ ] Follow existing code style and conventions

### 2. Testing
- [ ] Run `flutter test` - ensure all tests pass
- [ ] Add tests for new functionality if applicable
- [ ] Test on target platform (run the app)

### 3. Build Verification
- [ ] Run `flutter build` for target platform to verify build succeeds
- [ ] No compilation errors

### 4. General
- [ ] No unused imports or dead code
- [ ] Korean comments are acceptable
- [ ] Git commit messages in Korean (per user preference)
- [ ] No `Co-Authored-By` lines in commits

## Quick Commands for Task Completion
```bash
# Full verification sequence
dart format . && flutter analyze && flutter test

# Build check (pick appropriate platform)
flutter build apk  # Android
flutter build ios  # iOS
flutter build macos # macOS
flutter build web  # Web
```
