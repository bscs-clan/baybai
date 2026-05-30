# Baybai UI Refactoring Plan

## Clean Architecture + Shadcn Flutter + Reusable Component System

### Executive Summary

Your project has a **solid Clean Architecture foundation** with properly organized features and centralized theming. This refactor will:

- Consolidate scattered UI components into a unified system
- Create Shadcn Flutter-based reusable components
- Eliminate styling duplication
- Establish component naming and structure conventions

---

## Phase 1: Foundation Setup

### 1.1 Create Component Architecture

```
lib/shared/components/
├── README.md                          [Component library documentation]
├── base/                              [Reusable mixins & utilities]
│   ├── theme_aware.dart              [Dark mode handling mixin]
│   └── component_styles.dart         [Standardized styling utilities]
├── buttons/
│   ├── button.dart                   [Primary button component]
│   ├── icon_button.dart              [Icon button variant]
│   └── ghost_button.dart             [Ghost button variant]
├── cards/
│   ├── card.dart                     [Base card component]
│   ├── explore_card.dart             [Shadcn variant: Explore card]
│   └── lesson_card.dart              [Shadcn variant: Lesson card]
├── navigation/
│   ├── app_bar.dart                  [Global app bar]
│   └── bottom_nav.dart               [Bottom navigation]
├── inputs/
│   ├── text_input.dart               [Text input field]
│   └── select_input.dart             [Select/dropdown]
└── layout/
    ├── safe_area_layout.dart         [Safe area wrapper]
    └── section_container.dart        [Reusable section wrapper]
```

### 1.2 Create Theme Utilities

**File: `lib/shared/components/base/theme_aware.dart`**

- Mixin to avoid repeating dark mode checks
- Standardized color resolution
- Consistent shadow utilities

**File: `lib/shared/components/base/component_styles.dart`**

- Border radius constants
- Shadow definitions
- Padding/margin scale
- Animation durations

---

## Phase 2: Component Consolidation

### 2.1 Move & Refactor Buttons

**MOVE FROM:**

- `lib/shared/widgets/button.dart` → Enhanced and moved to `lib/shared/components/buttons/button.dart`

**CURRENT ISSUES:**

- ❌ Type enum (primary, secondary, outline) works, but variants undefined
- ❌ Size enum incomplete (inconsistent padding mappings)

**SOLUTION:**

- Create base button mixin with standard button properties
- Define Shadcn button variants (primary, secondary, outline, ghost)
- Standardize sizing system
- Extract color logic into reusable functions

### 2.2 Move & Refactor Cards

**MOVE FROM:**

- `features/home/presentation/widgets/explore_card.dart` → `lib/shared/components/cards/explore_card.dart`
- `features/home/presentation/widgets/learn_card.dart` → `lib/shared/components/cards/lesson_card.dart`

**MAKE REUSABLE:**

- Remove feature-specific assumptions
- Extract container styling into base card component
- Make icon, label, metadata configurable

### 2.3 Move Global Navigation

**MOVE FROM:**

- `features/home/presentation/widgets/app_bar.dart` → `lib/shared/components/navigation/app_bar.dart`
- `features/home/presentation/widgets/bottom_nav.dart` → `lib/shared/components/navigation/bottom_nav.dart`

**REFACTOR:**

- Make app bar flexible (title, actions configurable)
- Separate nav item definition from rendering logic

---

## Phase 3: Create Reusable Patterns

### 3.1 Establish Component Base Classes

**`theme_aware.dart` (Mixin)**

```dart
mixin ThemeAware {
  bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

  Color resolveColor({
    required BuildContext context,
    required Color lightColor,
    required Color darkColor,
  }) => isDarkMode(context) ? darkColor : lightColor;
}
```

### 3.2 Create Component Style Utilities

**`component_styles.dart`**

```dart
class ComponentRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class ComponentShadow {
  static final BoxShadow elevated = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static final BoxShadow floating = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 32,
    spreadRadius: 8,
    offset: const Offset(0, -6),
  );
}

class ComponentPadding {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
}
```

### 3.3 Create Shadcn Component Variants

**Example: `cards/card.dart` (Base Component)**

```dart
class Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final BoxDecoration? customDecoration;

  const Card({
    required this.child,
    this.padding,
    this.borderRadius,
    this.customDecoration,
  });

  @override
  Widget build(BuildContext context) {
    // Renders base card with theme-aware styling
  }
}
```

---

## Phase 4: Update Features to Use New Components

### 4.1 Update Home Feature

**File: `features/home/presentation/pages/home.dart`**

- Import from `lib/shared/components/` instead of local widgets
- Remove local widget definitions
- Update references: `ExploreCard` → existing, `LearnCard` → `LessonCard`

### 4.2 Update Other Features

- Scan Feature: Use `Button` from shared components
- Practice Feature: Use `Card` base component
- Quiz Feature: Use standardized components

---

## Phase 5: Architecture Enforcement Rules

### ✅ ALLOWED in `/shared/components/`

- Reusable UI components
- Styling utilities (colors, shadows, radii)
- Theme-aware mixins
- Component composition patterns

### ❌ FORBIDDEN in `/shared/components/`

- Business logic
- API calls
- State management (BLoC/Cubit)
- Feature-specific features

### ✅ ALLOWED in `/features/*/presentation/widgets/`

- Feature-specific component compositions
- Feature-specific layouts
- Local state widgets (animations, interactions)

---

## Component Migration Checklist

### New Components to Create

- [ ] `base/theme_aware.dart` - Dark mode mixin
- [ ] `base/component_styles.dart` - Style constants
- [ ] `buttons/button.dart` - Consolidated button (MOVE from shared/widgets)
- [ ] `buttons/icon_button.dart` - Icon button variant
- [ ] `cards/card.dart` - Base card component
- [ ] `cards/explore_card.dart` - Explore card (MOVE from home/widgets)
- [ ] `cards/lesson_card.dart` - Lesson card (MOVE from home/widgets)
- [ ] `navigation/app_bar.dart` - Global app bar (MOVE from home/widgets)
- [ ] `navigation/bottom_nav.dart` - Bottom nav (MOVE from home/widgets)
- [ ] `inputs/text_input.dart` - Text input
- [ ] `inputs/select_input.dart` - Select field
- [ ] `layout/safe_area_layout.dart` - Safe area wrapper
- [ ] `layout/section_container.dart` - Section wrapper

### Files to Update

- [ ] `lib/features/home/presentation/pages/home.dart` - Update imports
- [ ] `lib/features/home/presentation/pages/tab_learn.dart` - Update imports
- [ ] `lib/features/home/presentation/pages/tab_transliterate.dart` - Update imports
- [ ] `lib/main.dart` - Update app bar import
- [ ] All feature pages using `Button`, cards, inputs

### Files to Delete

- [ ] `lib/shared/widgets/button.dart` (consolidated into components)

---

## Expected Outcomes

### Before Refactor

```
- Button color logic scattered
- Dark mode check in every widget
- Card styling repeated 3+ times
- No component documentation
- Feature-specific widgets mixed with global components
- 50+ lines of duplicate styling code
```

### After Refactor

```
✅ Single source of truth for Button (3 types, 3 sizes)
✅ Dark mode handled via ThemeAware mixin
✅ Card styling centralized in base component
✅ Component library documented in README
✅ Clear boundary: shared/components ← global, features/*/widgets ← local
✅ Styling extracted to constants (10% code reduction)
```

---

## Next Steps

1. **Review this plan** - Confirm structure and naming
2. **Run Phase 1** - Create directory structure and base utilities
3. **Run Phase 2** - Move and consolidate components
4. **Run Phase 3** - Create reusable patterns and mixins
5. **Run Phase 4** - Update features to use new components
6. **Run Phase 5** - Cleanup and documentation

---

## Design Principles

### Reusability

Every component in `shared/components/` must be:

- **Configurable** - Accept parameters instead of hardcoding
- **Composable** - Work well with other components
- **Stateless** - No internal business logic

### Consistency

- Use `ThemeAware` mixin for dark mode
- Use `ComponentStyles` for all sizing/spacing/shadows
- Follow Shadcn Flutter naming conventions

### Architecture Purity

- No business logic in UI layer
- Components only render state, don't own it
- BLoC/Cubit stay in presentation layer (not components)

---

**Document Version:** 1.0
**Status:** Ready for Implementation
