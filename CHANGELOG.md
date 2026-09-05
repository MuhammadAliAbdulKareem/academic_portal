# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.3.0] - 2026-09-05 — Authentication

### Added
- Domain entity `UserEntity` and `UserRole` (`Instructor`, `Student`) defining role permissions.
- `AuthRepository` and `AuthRepositoryImpl` with `FirebaseAuth` integration and fallback persistence.
- `UserModel` data transfer object with Firestore and JSON serialization.
- `AuthCubit` state management handling registration, login, logout, and session state emissions.
- Modern `LoginScreen` with form validation, password visibility toggle, error notifications, and quick demo credentials shortcuts.
- `RegisterScreen` featuring visual academic role selector (`Instructor` vs `Student`), field validations, and confirmation matching.
- Protected route redirection guards in `AppRouter` based on active authentication state.
- Dynamic user profile pill and role badges in `PortalNavigationShell` header with quick sign-out.
- Comprehensive unit and widget tests for authentication flows (13 total test cases passing).

### Technical Details
- Zero static analysis or lint warnings (`flutter analyze`).
- Web release compilation verified (`flutter build web --release`).

## [v0.2.0] - 2026-09-05 — Design System

### Added
- Standardized design system tokens for multi-layered elevation shadows (`AppShadows`) and micro-interaction animations (`AppAnimations`).
- Reusable atomic UI components:
  - `PortalButton`: High-performance button supporting `primary`, `secondary`, `outline`, `ghost`, and `destructive` variants with integrated loading states and tap-scale feedback.
  - `PortalCard`: Animated surface container with elevation lift on hover and border highlight.
  - `PortalBadge`: Semantic status, role indicators (`Instructor`, `Student`), and category tags with dot and icon options.
  - `PortalAvatar`: User profile avatar with initials parsing, image fallback, and online presence indicator.
- Form controls:
  - `PortalTextField`: Validated input field supporting floating labels, search variants, and password obfuscation toggles.
- Loading and Empty State indicators:
  - `PortalSkeleton`: Smooth shimmer animation for cards, circular avatars, and text lines.
  - `PortalEmptyState`: Clean illustrated component for empty collections with call-to-action button.
- Adaptive Layout & Shell:
  - `PortalNavigationShell`: Responsive shell with desktop navigation rail, tablet collapsed rail, mobile bottom navigation bar, and integrated theme toggle.
- Interactive Component Showcase:
  - `DesignSystemScreen` accessible at `/design-system` for visual component testing across light and dark themes.
- Automated widget test suite covering button interactions, text field inputs, badge rendering, avatar initials, and skeleton shimmers.

### Technical Details
- 9 total tests passing cleanly (`flutter test`).
- 0 lint or static analysis issues (`flutter analyze`).
- Production web bundle compiled (`flutter build web --release`).

## [v0.1.0] - 2026-09-05 — Project Foundation

### Added
- Feature-based Clean Architecture structure (`core/`, `app/`, `features/`).
- Cross-platform Firebase foundation with safe fallback handling for Web, Mobile, and Desktop.
- GoRouter declarative routing system with `/`, `/foundation`, 404 error page, and placeholder navigation.
- BLoC state management foundation with `AppBlocObserver` and `ThemeCubit` for dynamic theme switching (System / Light / Dark).
- Design System tokens: Oxford Sapphire, Slate, Midnight Dark palettes, and Google Fonts typography (Outfit & Inter).
- Responsive breakpoint layout utilities (`Breakpoint`, `ResponsiveLayout`, `ResponsiveBuilder`, and `ResponsiveContextExtensions`).
- Interactive Foundation Status screen showcasing responsive behavior, theme toggling, and architectural health.
- Automated widget and unit tests validating startup, responsive breakpoints, and theme transitions.

### Technical Details
- Dart SDK: `^3.9.0`
- Flutter Web release build verified (`build/web`).
- Zero analysis issues on `flutter analyze`.
