import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academic_portal/core/design_system/components/portal_avatar.dart';
import 'package:academic_portal/core/design_system/components/portal_badge.dart';
import 'package:academic_portal/core/design_system/components/portal_button.dart';
import 'package:academic_portal/core/design_system/components/portal_empty_state.dart';
import 'package:academic_portal/core/design_system/components/portal_skeleton.dart';
import 'package:academic_portal/core/design_system/components/portal_text_field.dart';

void main() {
  group('Design System Components Tests', () {
    testWidgets('PortalButton triggers tap and handles loading state',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalButton(
              label: 'Submit Course',
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );

      expect(find.text('Submit Course'), findsOneWidget);
      await tester.tap(find.byType(PortalButton));
      await tester.pump();
      expect(tapCount, 1);

      // Loading state test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalButton(
              label: 'Loading Button',
              isLoading: true,
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(PortalButton));
      await tester.pump();
      // tap count should NOT increment while loading
      expect(tapCount, 1);
    });

    testWidgets('PortalTextField accepts input and toggles password visibility',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalTextField(
              label: 'User Password',
              hintText: 'Enter password',
              isPassword: true,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('User Password'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'SecureP@ss123');
      expect(controller.text, 'SecureP@ss123');

      // Password visibility toggle test
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('PortalBadge renders semantic content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PortalBadge(
              label: 'Instructor',
              variant: PortalBadgeVariant.instructor,
              hasDot: true,
            ),
          ),
        ),
      );

      expect(find.text('Instructor'), findsOneWidget);
    });

    testWidgets('PortalAvatar generates initials and presence indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PortalAvatar(
              name: 'Dr. Katherine Johnson',
              isOnline: true,
            ),
          ),
        ),
      );

      // Should extract initials from first and last tokens: "DJ"
      expect(find.text('DJ'), findsOneWidget);
    });

    testWidgets('PortalEmptyState displays illustration and action',
        (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalEmptyState(
              title: 'No Assignments Due',
              description: 'You have completed all pending course assignments.',
              actionLabel: 'Refresh List',
              onActionPressed: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Assignments Due'), findsOneWidget);
      expect(find.text('Refresh List'), findsOneWidget);

      await tester.tap(find.text('Refresh List'));
      await tester.pump();
      expect(actionTapped, true);
    });

    testWidgets('PortalSkeleton renders animated shimmering container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PortalSkeleton.card(height: 120),
          ),
        ),
      );

      expect(find.byType(PortalSkeleton), findsOneWidget);
    });
  });
}
