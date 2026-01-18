# Phase 1: UI Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add bottom button bar, scroll hint, bold filter, settings page with theme support, and clear all memos feature.

**Architecture:** Extend existing HomeScreen with new button bar, add SettingsScreen as new route, use Provider for theme state management, add scroll controller for bounce animation.

**Tech Stack:** Flutter, SharedPreferences, Provider (new dependency)

---

## Task 1: Add Provider Dependency

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add provider package**

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  uuid: ^4.2.1
  provider: ^6.1.1  # ADD THIS LINE
```

**Step 2: Run pub get**

Run: `flutter pub get`
Expected: Dependencies resolved successfully

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: provider 패키지 추가"
```

---

## Task 2: Create Theme Provider

**Files:**
- Create: `lib/providers/theme_provider.dart`

**Step 1: Create theme provider**

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAF6E9);
  static const Color lightPipe = Color(0xFFCCCCCC);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkPipe = Color(0xFF3A3A3C);

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    _themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => AppThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  ThemeMode get systemThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  Color backgroundColor(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  Color pipeColor(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    return brightness == Brightness.dark ? darkPipe : lightPipe;
  }

  Color buttonColor(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    return brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[400]!;
  }

  Brightness _getEffectiveBrightness(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context);
    }
    return _themeMode == AppThemeMode.dark ? Brightness.dark : Brightness.light;
  }
}
```

**Step 2: Commit**

```bash
git add lib/providers/theme_provider.dart
git commit -m "feat: ThemeProvider 추가 (system/light/dark)"
```

---

## Task 3: Wire Provider to App

**Files:**
- Modify: `lib/main.dart`

**Step 1: Wrap app with provider**

Replace entire `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SimpleMemoApp(),
    ),
  );
}

class SimpleMemoApp extends StatelessWidget {
  const SimpleMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Simple Memo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.systemThemeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

**Step 2: Test app launches**

Run: `flutter run`
Expected: App launches without errors

**Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: Provider로 테마 상태 관리 연결"
```

---

## Task 4: Create Settings Screen

**Files:**
- Create: `lib/screens/settings_screen.dart`

**Step 1: Create settings screen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.backgroundColor(context);
    final textColor = themeProvider._getEffectiveBrightness(context) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Theme Section
          ListTile(
            title: Text('Theme', style: TextStyle(color: textColor)),
            trailing: DropdownButton<AppThemeMode>(
              value: themeProvider.themeMode,
              dropdownColor: backgroundColor,
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Sync Section (placeholder for Phase 2)
          ListTile(
            title: Text('Sync', style: TextStyle(color: textColor)),
            subtitle: Text('Sign in to sync', style: TextStyle(color: textColor.withOpacity(0.6))),
            trailing: Icon(Icons.chevron_right, color: textColor),
            onTap: () {
              // TODO: Phase 2 - Supabase sync
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          const Divider(),

          // Danger Zone
          const SizedBox(height: 32),
          ListTile(
            title: const Text(
              '메모 모두 지우기',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _clearAllMemos(context),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllMemos(BuildContext context) async {
    final storageService = StorageService();
    await storageService.saveMemos([]);
    if (context.mounted) {
      Navigator.of(context).pop(true); // Return true to indicate memos cleared
    }
  }
}
```

**Step 2: Fix private method access issue**

The `_getEffectiveBrightness` is private. Update `theme_provider.dart` to add a public helper:

In `lib/providers/theme_provider.dart`, add this public method:

```dart
  bool isDark(BuildContext context) {
    return _getEffectiveBrightness(context) == Brightness.dark;
  }
```

**Step 3: Update settings_screen.dart to use isDark**

Replace the textColor line:

```dart
    final isDark = themeProvider.isDark(context);
    final textColor = isDark ? Colors.white : Colors.black87;
```

**Step 4: Commit**

```bash
git add lib/screens/settings_screen.dart lib/providers/theme_provider.dart
git commit -m "feat: Settings 화면 추가 (테마 선택, 메모 전체 삭제)"
```

---

## Task 5: Update HomeScreen with Theme Support

**Files:**
- Modify: `lib/screens/home_screen.dart`

**Step 1: Import provider and update background color**

Add import at top:
```dart
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
```

**Step 2: Update build method to use theme**

In `_HomeScreenState.build()`, replace:
```dart
  static const Color _backgroundColor = Color(0xFFFAF6E9);
```

With dynamic color in build method:
```dart
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.backgroundColor(context);
```

And update Scaffold:
```dart
    return Scaffold(
      backgroundColor: backgroundColor,
      // ... rest
    );
```

**Step 3: Update pipe color in MemoDisplay**

Pass pipe color to MemoDisplay and use it. Add parameter:
```dart
final Color pipeColor;
```

**Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: HomeScreen 테마 지원 추가"
```

---

## Task 6: Bottom Button Bar

**Files:**
- Modify: `lib/screens/home_screen.dart`

**Step 1: Add filter state to _HomeScreenState**

```dart
  bool _isBoldFilterActive = false;
```

**Step 2: Replace floatingActionButton with bottom button bar**

Replace the `floatingActionButton` property with `bottomNavigationBar`:

```dart
      bottomNavigationBar: _isEditing
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add button
                  _buildBottomButton(
                    icon: Icons.add,
                    onPressed: _startEditing,
                    isActive: false,
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(width: 8),
                  // Filter button
                  _buildBottomButton(
                    icon: Icons.filter_list,
                    onPressed: _toggleBoldFilter,
                    isActive: _isBoldFilterActive,
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(width: 8),
                  // Settings button
                  _buildBottomButton(
                    icon: Icons.settings,
                    onPressed: () => _openSettings(context),
                    isActive: false,
                    themeProvider: themeProvider,
                  ),
                ],
              ),
            ),
```

**Step 3: Add helper methods**

```dart
  Widget _buildBottomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    required ThemeProvider themeProvider,
  }) {
    return SizedBox(
      width: 36,
      height: 24,
      child: Material(
        color: isActive ? Colors.grey[600] : Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(3),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }

  void _toggleBoldFilter() {
    setState(() {
      _isBoldFilterActive = !_isBoldFilterActive;
    });
  }

  Future<void> _openSettings(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (result == true) {
      // Memos were cleared, reload
      await _loadMemos();
    }
  }
```

**Step 4: Add import for SettingsScreen**

```dart
import 'settings_screen.dart';
```

**Step 5: Remove old floatingActionButton code**

Delete the entire `floatingActionButton:` property.

**Step 6: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: 하단 버튼 바 추가 (추가, 필터, 설정)"
```

---

## Task 7: Bold Filter Effect

**Files:**
- Modify: `lib/screens/home_screen.dart`

**Step 1: Pass filter state to MemoDisplay**

Add parameter to MemoDisplay:
```dart
  final bool isBoldFilterActive;
```

Update MemoDisplay constructor and call site.

**Step 2: Update _SwipeableMemo to apply filter effect**

In `_SwipeableMemoState.build()`, calculate styles based on filter:

```dart
  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_swipeOffset.abs() / _deleteThreshold * 0.7)).clamp(0.3, 1.0);

    // Bold filter effect
    final isFiltered = widget.isBoldFilterActive && !widget.memo.isBold;
    final filterOpacity = isFiltered ? 0.3 : 1.0;
    final fontSize = isFiltered ? 12.0 : 16.0;

    final effectiveOpacity = opacity * filterOpacity;

    return GestureDetector(
      // ... gestures
      child: Transform.translate(
        offset: Offset(_swipeOffset, 0),
        child: Opacity(
          opacity: effectiveOpacity,
          child: Text(
            widget.memo.title,
            style: TextStyle(
              color: Color(widget.memo.colorValue),
              fontSize: fontSize,
              fontWeight: widget.memo.isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
```

**Step 3: Add isBoldFilterActive parameter to _SwipeableMemo**

```dart
  final bool isBoldFilterActive;
```

Update constructor and all call sites.

**Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: Bold 필터 효과 추가 (dim + shrink)"
```

---

## Task 8: Scroll Hint - Fade Gradient

**Files:**
- Modify: `lib/screens/home_screen.dart`

**Step 1: Wrap SingleChildScrollView with ShaderMask**

In `_HomeScreenState.build()`, wrap the scroll area:

```dart
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.02, 0.98, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              // ... existing code
            ),
          ),
```

**Step 2: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: 스크롤 영역 상하단 페이드 효과 추가"
```

---

## Task 9: Scroll Hint - Bounce Animation

**Files:**
- Modify: `lib/screens/home_screen.dart`

**Step 1: Add ScrollController and animation state**

```dart
  final ScrollController _scrollController = ScrollController();
  bool _hasShownScrollHint = false;
```

**Step 2: Add method to trigger bounce**

```dart
  void _showScrollHint() {
    if (_hasShownScrollHint) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) return;

    _hasShownScrollHint = true;

    // Bounce down then back
    _scrollController.animateTo(
      20,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    ).then((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }
```

**Step 3: Call after memos load**

In `_loadMemos()`, after setState:
```dart
    // Show scroll hint after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showScrollHint();
    });
```

**Step 4: Attach controller to SingleChildScrollView**

```dart
            child: SingleChildScrollView(
              controller: _scrollController,
              // ...
            ),
```

**Step 5: Dispose controller**

In `dispose()`:
```dart
    _scrollController.dispose();
```

**Step 6: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: 스크롤 힌트 bounce 애니메이션 추가"
```

---

## Task 10: Final Integration Test

**Step 1: Run the app**

Run: `flutter run`

**Step 2: Manual test checklist**

- [ ] Bottom buttons visible (Add, Filter, Settings) - center aligned
- [ ] Add button works (opens input)
- [ ] Filter button toggles bold filter (non-bold memos dim + shrink)
- [ ] Settings button opens settings page
- [ ] Theme dropdown works (System/Light/Dark)
- [ ] "메모 모두 지우기" clears all memos
- [ ] Fade gradient visible at top/bottom of memo area
- [ ] Bounce animation triggers on app load (if memos overflow)

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: Phase 1 UI 개선 완료"
git push
```

---

## Summary

| Task | Feature |
|------|---------|
| 1 | Provider dependency |
| 2 | ThemeProvider |
| 3 | Wire provider to app |
| 4 | Settings screen |
| 5 | HomeScreen theme support |
| 6 | Bottom button bar |
| 7 | Bold filter effect |
| 8 | Fade gradient |
| 9 | Bounce animation |
| 10 | Integration test |
