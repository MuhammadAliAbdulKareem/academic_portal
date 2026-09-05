import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academic_portal/app/app.dart';
import 'package:academic_portal/core/bloc/theme_cubit.dart';
import 'package:academic_portal/core/constants/app_constants.dart';
import 'package:academic_portal/core/responsive/breakpoint.dart';

void main() {
  group('Project Foundation Tests', () {
    testWidgets('AcademicPortalApp renders foundation screen successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(const AcademicPortalApp());
      await tester.pumpAndSettle();

      // Verify app branding is present
      expect(find.text(AppConstants.appName), findsWidgets);
      expect(find.text('Academic Portal Platform'), findsOneWidget);
      expect(find.text(AppConstants.appTagline), findsOneWidget);

      // Verify architectural modules are rendered
      expect(find.text('Feature-Based Architecture'), findsOneWidget);
      expect(find.text('Firebase Core & Services'), findsOneWidget);
      expect(find.text('GoRouter Declarative Navigation'), findsOneWidget);
      expect(find.text('BLoC State Management'), findsOneWidget);
    });

    test('Breakpoint categorization handles widths correctly', () {
      expect(Breakpoint.fromWidth(400), DeviceScreenType.mobile);
      expect(Breakpoint.fromWidth(599), DeviceScreenType.mobile);
      expect(Breakpoint.fromWidth(600), DeviceScreenType.tablet);
      expect(Breakpoint.fromWidth(1023), DeviceScreenType.tablet);
      expect(Breakpoint.fromWidth(1024), DeviceScreenType.desktop);
      expect(Breakpoint.fromWidth(1920), DeviceScreenType.desktop);
    });

    test('ThemeCubit emits correct theme states', () {
      final themeCubit = ThemeCubit();

      expect(themeCubit.state.themeMode, ThemeMode.system);

      themeCubit.setThemeMode(ThemeMode.dark);
      expect(themeCubit.state.themeMode, ThemeMode.dark);

      themeCubit.toggleTheme();
      expect(themeCubit.state.themeMode, ThemeMode.light);

      themeCubit.toggleTheme();
      expect(themeCubit.state.themeMode, ThemeMode.dark);

      themeCubit.close();
    });
  });
}
