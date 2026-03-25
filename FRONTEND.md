# 🚀 FRONTEND DEVELOPMENT GUIDELINES (MOBILE - FLUTTER)

## 🎯 PURPOSE

This document defines strict rules, standards, and best practices for building a scalable, clean, and production-ready frontend using Flutter.

All developers and AI agents MUST follow these rules.

---

# 🧱 1. PROJECT STRUCTURE (CLEAN ARCHITECTURE)

lib/
│
├── core/                  # Global utilities
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   └── widgets/           # Reusable global widgets
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── home/
│   ├── coach/
│   ├── simulator/
│   └── profile/
│
├── services/              # API / Supabase / AI calls
├── providers/             # Riverpod providers
└── main.dart

---

# 🎨 2. UI/UX DESIGN RULES

## 2.1 Design System

* Use Material 3 with custom theming
* Support BOTH dark and light mode
* Use consistent spacing system (8px grid)

## 2.2 Typography

* Use Google Fonts (Inter / Poppins)
* Define in theme.dart
* No inline font styling

## 2.3 Colors

* Define ALL colors in theme.dart
* Avoid hardcoding colors

## 2.4 Spacing

* Use constants:

  * spacingXS = 4
  * spacingSM = 8
  * spacingMD = 16
  * spacingLG = 24
  * spacingXL = 32

---

# 🧩 3. COMPONENT RULES

## 3.1 Reusability

* Every repeated UI MUST be a reusable widget
* Example:

  * AppButton
  * AppCard
  * AppTextField

## 3.2 Naming Convention

* PascalCase for widgets
* Example:

  * PrimaryButton
  * MessageCard

## 3.3 No UI Logic Mixing

❌ Avoid:

* API calls inside UI
* Business logic inside widgets

---

# ⚙️ 4. STATE MANAGEMENT (RIVERPOD)

## Rules:

* Use Riverpod for ALL state management
* Separate providers by feature

## Structure:

* state/
* providers/
* controllers/

## DO:

* Use StateNotifier / AsyncNotifier
* Handle loading, success, error states

---

# 🔌 5. API & DATA HANDLING

## Rules:

* NO direct API calls in UI
* Use service layer

## Flow:

UI → Provider → Service → API

## Error Handling:

* Show user-friendly messages
* Never crash UI

---

# 🔐 6. SECURITY RULES

* Never store API keys in plain text
* Use flutter_secure_storage
* No sensitive data in logs

---

# ⚡ 7. PERFORMANCE RULES

* Use const widgets wherever possible
* Avoid unnecessary rebuilds
* Use ListView.builder for lists
* Lazy load heavy data

---

# 🎭 8. ANIMATION & INTERACTIONS

* Use subtle animations only
* Use flutter_animate or AnimatedContainer
* Avoid over-animation

---

# 🧪 9. LOADING & ERROR STATES

## MUST HANDLE:

* Loading → shimmer/skeleton
* Error → retry button
* Empty → proper UI message

---

# 🧼 10. CODE QUALITY

## Formatting:

* Follow Dart formatting rules
* Use meaningful variable names

## DO:

* Small, focused widgets
* Max 200–300 lines per file

## DON’T:

* Giant widgets
* Nested complexity

---

# 🌗 11. THEME SYSTEM

* Centralized theme config
* Use Theme.of(context)
* No hardcoded styles

---

# 📱 12. RESPONSIVENESS

* Support all screen sizes
* Use MediaQuery / LayoutBuilder
* Avoid fixed widths/heights

---

# 🧱 13. NAVIGATION

* Use GoRouter (recommended)
* Centralized route config
* Avoid inline navigation logic

---

# 📦 14. DEPENDENCIES (ONLY FREE)

Allowed:

* flutter_riverpod
* go_router
* flutter_secure_storage
* fl_chart
* lottie
* shimmer
* flutter_animate

Avoid:

* Heavy or paid libraries

---

# 🧠 15. AI INTEGRATION RULES

* AI calls go through backend (Supabase Edge Functions)
* Never call AI directly from UI
* Always handle timeout + errors

---

# 🧾 16. LOGGING & DEBUGGING

* Use debugPrint (not print)
* Disable logs in production

---

# 🚀 17. FINAL CHECKLIST

Before completing any feature:

✅ UI matches design
✅ Code is reusable
✅ No hardcoding
✅ State handled properly
✅ Error handling added
✅ Dark mode supported
✅ Performance optimized

---

# ❗ STRICT RULE

If any code violates these standards, it must be refactored before merging.

---

END OF DOCUMENT
