# Simple Memo - Feature Roadmap

## Bug Fixes
- [x] Fix `RenderFlex overflowed by X pixels on the right` - switched to pixel-based text width limit (2026-01-18)
- [x] Fix memo display covering entire screen - added 80% max height constraint with scrolling (2026-01-18)
- [x] Fix input box color changing on save - now uses color selected at edit start (2026-01-18)
- [x] Fix swipe delete leaving empty area + pipe - added ValueKey for proper widget rebuild (2026-01-18)

## Branding
- [ ] Decide app name (currently "simple_memo")
- [ ] Design app icon

## Planned Features

### Authentication (Phase 2)
- [ ] Google social login (Supabase OAuth)
- [ ] Apple social login (Supabase OAuth)

### Cloud Sync (Phase 2 - Design: docs/plans/2026-01-18-ui-and-sync-design.md)
- [ ] Supabase integration
- [ ] Offline-first sync (local + cloud merge)
- [ ] Multi-device support

### Memo Interactions (Design: docs/plans/2026-01-18-memo-interactions-design.md)
- [x] Long press → copy memo to clipboard (with snackbar confirmation)
- [x] Tap → inline edit at memo position (replaces memo with TextField)
- [x] Double tap → toggle bold text (persisted to storage)
- [ ] Press and drag → reorder (temporarily disabled - gesture conflicts)
- [x] Swipe (left/right 50px) → delete memo with fade effect

**Implementation Status:** 4/5 gestures complete (2026-01-18)
- Drag reorder disabled due to conflict with long press copy
- May revisit with drag handle icon or alternative UX

### Monetization
- [ ] Google AdMob integration for ad revenue (BM)

---

## Completed Features

### Phase 1: UI Improvements (2026-01-18) ✅
- [x] Bottom button bar (center-aligned: Add, Filter, Settings)
- [x] Bold filter toggle (dim 40% + shrink 12px for non-bold memos)
- [x] Scroll hint - fade gradient (top/bottom 5%)
- [x] Scroll hint - bounce animation on load
- [x] Settings screen
- [x] Theme support (system/light/dark)
- [x] Clear all memos (permanent delete, no confirmation)
- [x] AdMob space reserved (bottom padding 60px)

---

## Current Features (as of 2026-01-18)

### Core
- Add memo with + button (bottom bar)
- Delete memo via swipe (left or right)
- Auto-color assignment (5 muted/dusty tones)
- Pixel-based width limit (300px max) - adapts to character width (Korean ~18, English ~35)
- Persistent storage via SharedPreferences
- Clear all memos (Settings → 메모 모두 지우기)

### UI/UX
- Bottom button bar: Add, Filter, Settings (center-aligned)
- Bold filter: dims + shrinks non-bold memos
- Inline editing (tap memo → edit in place)
- New memo input appears at first position
- Pipe separators between memos
- Theme support (system/light/dark)
- Scroll fade gradient (top/bottom edges)
- Scroll bounce hint on load
- Memo display constrained to 80% screen height
- Scrollable memo area

### Gestures
| Gesture | Action |
|---------|--------|
| Tap | Edit memo inline |
| Double tap | Toggle bold |
| Long press | Copy to clipboard |
| Swipe L/R | Delete memo |

### Data Model
- Memo: id, title, colorValue, createdAt, isBold
- JSON serialization for storage
- copyWith() for immutable updates

---

## Technical Notes

### Files Modified (Phase 1)
- `lib/main.dart` - Provider integration for theme
- `lib/providers/theme_provider.dart` - Theme state management (NEW)
- `lib/screens/home_screen.dart` - Bottom bar, filter, scroll hints
- `lib/screens/settings_screen.dart` - Settings page (NEW)
- `docs/plans/2026-01-18-ui-and-sync-design.md` - Phase 1 & 2 design
- `docs/plans/2026-01-18-phase1-ui-improvements.md` - Implementation plan

### Architecture
- `ThemeProvider` - ChangeNotifier for theme state (Provider package)
- `_SwipeableMemo` - StatefulWidget handling swipe detection
- `_DisplayItem` - Union type for memo or input field in flow layout
- Custom swipe detection (GestureDetector) instead of Dismissible
- ValueKey on memo widgets for proper reconciliation
- `_PixelWidthLimitingFormatter` - Custom TextInputFormatter for pixel-based input limiting
- `_measureTextWidth()` / `_trimToMaxWidth()` - TextPainter-based width measurement
- ShaderMask for scroll fade gradient
- ScrollController for bounce animation

### Dependencies
```yaml
dependencies:
  flutter: sdk
  shared_preferences: ^2.2.2
  uuid: ^4.2.1
  provider: ^6.1.1  # Added for Phase 1
```
