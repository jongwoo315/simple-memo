# Session: Weird Memo Display Issue

## Date: 2026-01-17

## Project: simple_memo (Flutter)

## Summary
Debugged a complex issue where memo text appeared to be truncated when saved, but the root cause was actually display layout constraints, not save logic.

## Issue Timeline

### 1. Initial Report
- User reported memo content being cut when too long
- Initial cause: `overflow: TextOverflow.ellipsis` in Text widget

### 2. Input Truncation Reports
- Korean: "사라지기 전에 빠른 메모" → displayed as "사라지기 전"
- English: "how do you do?" → displayed as "how do"
- Misdiagnosed as: maxLength enforcement issue, Korean IME issue

### 3. Failed Fix Attempts
- Added `maxLengthEnforcement`, `LengthLimitingTextInputFormatter`
- Added `_onTextChanged` that modified `_controller.text` - **this actually caused issues**
- Suspected async race conditions in `_onSubmitted`

### 4. Root Cause Discovery
- Screenshot comparison revealed same memo showing different text lengths
- **Actual cause**: Display layout constraints, NOT save logic
- `FractionallySizedBox` with `widthRatio` (circular layout effect)
- `Flexible` widget constraining text width
- `maxLines: 1` preventing wrapping
- Text was always saved correctly - just visually clipped

### 5. Resolution
- Removed `FractionallySizedBox` width constraints
- Changed from `Wrap` (caused overflow) to manual row calculation
- Rows calculated based on memo text width using `TextPainter`
- `Row` with `mainAxisSize: MainAxisSize.min` for proper sizing
- Pipes only between memos within same row (not at row end)

## Key Learnings

### Debugging Lesson
- Visual truncation vs data truncation are different problems
- Screenshots comparing same data in different states reveal layout issues
- Don't assume the obvious cause - verify with evidence

### Flutter Layout Insights
- `Flexible` in `Row` can cause text clipping without visible overflow
- `FractionallySizedBox` constrains children width proportionally
- `maxLines: 1` without `TextOverflow.ellipsis` silently clips text
- Modifying `TextEditingController.text` in listeners can interfere with IME input

### Korean IME Considerations
- Setting `_controller.text = ...` during input interrupts IME composition
- Read from controller, don't write during text changes
- `onSubmitted` value parameter may differ from `controller.text` during composition

## UI Changes Made
- Background: 누리끼리 (cream) color `#FAF6E9`
- Colors: Muted/dusty tones for better readability on cream background
- Removed: AppBar title, circular layout effect
- Added: Pipes between memos (within same row only)
- Button: Small grey rectangle for + button
- Max length: Changed from 50 to 30 characters

## Files Modified
- `lib/screens/home_screen.dart` - Main changes to layout and input handling
