# Memo Interactions Design

**Date:** 2026-01-18
**Status:** Ready for implementation

## Overview

Implement 5 new gesture-based interactions for memos in the Simple Memo app.

## Features

| Gesture | Action | Details |
|---------|--------|---------|
| Tap | Edit memo | Enter edit mode with existing memo content |
| Double tap | Toggle bold | Persist bold state to storage |
| Long press | Copy to clipboard | Copy memo title text |
| Long press + drag | Reorder | Visual drag, snap to new list position |
| Swipe (left or right) | Remove | Delete memo from list |

## Gesture Architecture

Widget nesting strategy to handle gesture conflicts:

```
Dismissible (swipe left/right → remove)
└── LongPressDraggable (long press + drag → reorder)
    └── GestureDetector
        ├── onTap → modify memo
        ├── onDoubleTap → toggle bold
        └── onLongPress → copy to clipboard
```

### Conflict Resolution

- `Dismissible` handles horizontal swipe exclusively
- `LongPressDraggable` triggers after ~500ms hold, then allows drag
- `onLongPress` fires if no drag detected after long press
- `onTap` vs `onDoubleTap`: Flutter waits ~300ms to distinguish

**Trade-off:** Tap will feel slightly delayed due to double-tap detection timing.

## Data Model Changes

### Current Model (`lib/models/memo.dart`)

```dart
class Memo {
  final String id;
  final String title;
  final int colorValue;
  final DateTime createdAt;
}
```

### Updated Model

```dart
class Memo {
  final String id;
  final String title;
  final int colorValue;
  final DateTime createdAt;
  final bool isBold;  // NEW - defaults to false
}
```

JSON serialization updated to include `isBold`. Existing saved memos without this field default to `false`.

## HomeScreen Changes

### New State

```dart
String? _editingMemoId;  // null = new memo, non-null = editing existing
```

### New/Modified Methods

```dart
// Modified (now triggered by swipe)
Future<void> _deleteMemo(String id)

// New methods
void _copyMemo(String id)                          // Long press
void _editMemo(String id)                          // Tap - populate input with memo
Future<void> _toggleBold(String id)                // Double tap
void _reorderMemo(int oldIndex, int newIndex)      // Drag drop
```

### Edit Mode Changes

- Currently: editing always creates NEW memo
- New: editing can MODIFY existing memo
- `_editingMemoId` tracks whether editing new vs existing
- On submit: if `_editingMemoId` is set, update existing memo; else create new

## MemoDisplay Widget Changes

### New Callbacks

```dart
const MemoDisplay({
  required this.memos,
  required this.onDelete,
  required this.onEdit,      // NEW
  required this.onCopy,      // NEW
  required this.onToggleBold, // NEW
  required this.onReorder,   // NEW
});
```

### Updated Memo Widget Structure

```dart
Dismissible(
  key: Key(memo.id),
  direction: DismissDirection.horizontal,
  onDismissed: (_) => onDelete(memo.id),
  background: Container(color: Colors.red.withOpacity(0.3)),
  child: LongPressDraggable<Memo>(
    data: memo,
    feedback: Material(
      color: Colors.transparent,
      child: Text(memo.title, style: /* with shadow for visibility */),
    ),
    childWhenDragging: Opacity(opacity: 0.3, child: /* original */),
    onDragEnd: (details) => /* calculate drop position, call onReorder */,
    child: GestureDetector(
      onTap: () => onEdit(memo.id),
      onDoubleTap: () => onToggleBold(memo.id),
      onLongPress: () => onCopy(memo.id),
      child: Text(
        memo.title,
        style: TextStyle(
          fontWeight: memo.isBold ? FontWeight.bold : FontWeight.normal,
          color: Color(memo.colorValue),
          fontSize: 16,
        ),
      ),
    ),
  ),
)
```

## Files to Modify

1. `lib/models/memo.dart` - Add `isBold` field + JSON serialization
2. `lib/screens/home_screen.dart` - Callbacks, gesture widgets, edit mode

## Dependencies

No new dependencies needed - all widgets are Flutter core:
- `Dismissible` - flutter/material.dart
- `LongPressDraggable` - flutter/material.dart
- `Clipboard` - flutter/services.dart (already imported)

## Implementation Order

1. Update `Memo` model with `isBold` field
2. Add new callbacks in `_HomeScreenState`
3. Update `MemoDisplay` to accept new callbacks
4. Implement gesture widget nesting in `_buildRowWithPipes`
5. Implement edit mode for existing memos
6. Test all gestures for conflicts
