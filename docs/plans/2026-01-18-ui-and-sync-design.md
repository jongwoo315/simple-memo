# UI 개선 및 클라우드 동기화 설계

## 개요

메모 앱의 UI 개선 및 Supabase 기반 클라우드 동기화 기능 추가

## 1. Bottom Button Bar

**Layout:**
```
              [Add] [Filter] [Settings]
                ↑       ↑         ↑
            Current  Toggle    Opens
            behavior  bold    settings
                     filter    page
```

**Specs:**
- 3 buttons, same style as current (36x24px, gray, rounded corners)
- Icons: Add (plus), Filter (funnel), Settings (gear)
- Spacing: 8px between buttons
- Position: Bottom-center, 16px padding from bottom
- All buttons hide when editing memo

**Filter button states:**
- Default: Gray background (grey[400])
- Active: Darker gray (grey[600]) to indicate filtering

---

## 2. Scroll Hint

**Fade Gradient:**
- Top edge: Subtle fade from background (#FAF6E9) to transparent (8px height)
- Bottom edge: Same fade effect
- Only visible when content overflows

**Bounce Animation:**
- On app load, if memos overflow, auto-scroll down ~20px then back
- Duration: 400ms total (200ms down, 200ms back)
- Easing: ease-in-out
- Triggers once per app session

---

## 3. Bold Filter

**Toggle Behavior:**
- Tap filter button → non-bold memos become dim + smaller
- Tap again → restore all memos to normal

**Non-bold memos when filtered:**
- Opacity: 30%
- Font size: 12px (from 16px)
- Still visible, still interactive

**Bold memos when filtered:**
- No change (100% opacity, 16px font)

---

## 4. Clear All Memos

**Location:** Inside Settings page (danger zone section at bottom)

**Behavior:**
- Tap "메모 모두 지우기" → Permanent delete, no confirmation
- Clears both local storage and cloud (if logged in)

**Visual:**
```
┌─────────────────────────────┐
│  Settings                   │
├─────────────────────────────┤
│  Theme            [System ▼]│
│  Sync             [Sign in] │
├─────────────────────────────┤
│  ⚠️ 메모 모두 지우기         │  ← Red text
└─────────────────────────────┘
```

---

## 5. Settings - Theme

**Options:**
- System (default) - follows iOS dark/light setting
- Light - always cream background (#FAF6E9)
- Dark - dark background

**Dark Theme Colors:**
| Element | Light | Dark |
|---------|-------|------|
| Background | #FAF6E9 (cream) | #1C1C1E (iOS dark) |
| Memo colors | Current dusty tones | Slightly brighter |
| Pipe separator | #CCCCCC | #3A3A3C |
| Buttons | grey[400] | grey[600] |

**Storage:**
- SharedPreferences key: `theme_mode` → `system`, `light`, `dark`

---

## 6. Settings - Sync (Supabase)

**UI States:**

```
Logged out:
┌─────────────────────────────┐
│  Sync                       │
│  ┌─────────┐ ┌─────────┐   │
│  │  Google │ │  Apple  │   │
│  └─────────┘ └─────────┘   │
└─────────────────────────────┘

Logged in:
┌─────────────────────────────┐
│  Sync                       │
│  ✓ user@email.com           │
│  마지막 동기화: 방금 전       │
│  [로그아웃]                  │
└─────────────────────────────┘
```

**Login Flow:**
1. User taps Google/Apple button
2. OAuth flow via Supabase
3. On success: merge local memos with cloud
4. Start real-time sync

**Logout Flow:**
1. User taps 로그아웃
2. Stop sync, continue with local-only mode
3. Local memos preserved

**Sync Behavior:**
```
┌─────────────────────────────────────────────────┐
│  Logged Out          │  Logged In               │
├─────────────────────────────────────────────────┤
│  Local storage only  │  Local + Cloud sync      │
│  (SharedPreferences) │  (Supabase real-time)    │
└─────────────────────────────────────────────────┘
```

**Multi-device:** Merge local + cloud memos when logging in on new device

**Supabase Data Model:**
```sql
create table memos (
  id uuid primary key,
  user_id uuid references auth.users(id),
  title text not null,
  color_value int not null,
  is_bold boolean default false,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- Row Level Security
alter table memos enable row level security;

create policy "Users can CRUD own memos"
  on memos for all
  using (auth.uid() = user_id);
```

---

## Implementation Order

1. **Phase 1: UI Changes (no backend)**
   - Bottom button bar (center-aligned)
   - Scroll hint (fade + bounce)
   - Bold filter toggle
   - Settings page skeleton
   - Theme support (light/dark/system)
   - Clear all memos

2. **Phase 2: Supabase Integration**
   - Supabase project setup
   - Google/Apple OAuth configuration
   - Sync service implementation
   - Merge logic for multi-device

---

## Dependencies

```yaml
# pubspec.yaml additions
dependencies:
  supabase_flutter: ^2.0.0
```
