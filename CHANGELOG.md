# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
