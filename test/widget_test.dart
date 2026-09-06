import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academic_portal/app/app.dart';
import 'package:academic_portal/core/bloc/theme_cubit.dart';
import 'package:academic_portal/core/responsive/breakpoint.dart';

void main() {
  group('Project Foundation Tests', () {
    testWidgets('AcademicPortalApp renders portal login gateway successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(const AcademicPortalApp());
      await tester.pumpAndSettle();

      // Verify portal branding and login screen elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In to Portal'), findsOneWidget);
      expect(find.text('Instructor'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
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
