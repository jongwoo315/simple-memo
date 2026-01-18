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

### Authentication
- [ ] Google social login
- [ ] Apple social login

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

## Current Features (as of 2026-01-18)

### Core
- Add memo with + button
- Delete memo via swipe (left or right)
- Auto-color assignment (5 muted/dusty tones)
- Pixel-based width limit (300px max) - adapts to character width (Korean ~18, English ~35)
- Persistent storage via SharedPreferences

### UI/UX
- Inline editing (tap memo → edit in place)
- New memo input appears at first position
- Pipe separators between memos
- 누리끼리 (cream) background (#FAF6E9)
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

### Files Modified (2026-01-18)
- `lib/models/memo.dart` - Added isBold field, copyWith()
- `lib/screens/home_screen.dart` - Complete gesture system rewrite
- `docs/plans/2026-01-18-memo-interactions-design.md` - Design document

### Architecture
- `_SwipeableMemo` - StatefulWidget handling swipe detection
- `_DisplayItem` - Union type for memo or input field in flow layout
- Custom swipe detection (GestureDetector) instead of Dismissible
- ValueKey on memo widgets for proper reconciliation
- `_PixelWidthLimitingFormatter` - Custom TextInputFormatter for pixel-based input limiting
- `_measureTextWidth()` / `_trimToMaxWidth()` - TextPainter-based width measurement
