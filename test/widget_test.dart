import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apnamasteradmin/app/widgets/stat_card.dart';
import 'package:apnamasteradmin/app/widgets/user_card.dart';
import 'package:apnamasteradmin/app/widgets/confirmation_dialog.dart';
import 'package:apnamasteradmin/app/data/models/user_model.dart';
import 'package:apnamasteradmin/app/theme/app_colors.dart';

void main() {
  testWidgets('StatCard displays title and value accurately', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            title: 'Total Users',
            value: '125',
            icon: Icons.people_rounded,
            accentColor: AppColors.primary,
          ),
        ),
      ),
    );

    expect(find.text('TOTAL USERS'), findsOneWidget);
    expect(find.text('125'), findsOneWidget);
    expect(find.byIcon(Icons.people_rounded), findsOneWidget);
  });

  testWidgets('UserCard displays demo user and action buttons', (WidgetTester tester) async {
    final now = DateTime.now();
    final user = UserModel(
      id: 'piyu',
      pass: '12345678',
      deviceId: '5CCBEC204F42A5F6BA69ADF6C579574F',
      currentDate: now,
      expiryDate: now.add(const Duration(days: 3)),
      masterCode: 'MASTER_PIYUSH',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(
            user: user,
            onStartProduction: () {},
            onResetDeviceId: () {},
            onToggleStop: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('piyu'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
    expect(find.text('Start Production (30d)'), findsOneWidget);
    expect(find.text('Reset Device'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('UserCard displays STOPPED badge and Resume button when stopped', (WidgetTester tester) async {
    final now = DateTime.now();
    final stoppedUser = UserModel(
      id: 'stopped_user',
      pass: 'secret',
      currentDate: now,
      expiryDate: now.add(const Duration(days: 3)),
      stop: true,
      masterCode: 'MASTER_PIYUSH',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(
            user: stoppedUser,
            onStartProduction: () {},
            onResetDeviceId: () {},
            onToggleStop: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('stopped_user'), findsOneWidget);
    expect(find.text('STOPPED'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('UserCard hides Extend 30d button when production cycle is actively running', (WidgetTester tester) async {
    final now = DateTime.now();
    final activeProdUser = UserModel(
      id: 'active_prod',
      pass: 'secret',
      currentDate: now.subtract(const Duration(hours: 1)),
      expiryDate: now.add(const Duration(days: 30)),
      masterCode: 'MASTER_PIYUSH',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(
            user: activeProdUser,
            onStartProduction: () {},
            onResetDeviceId: () {},
            onToggleStop: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('active_prod'), findsOneWidget);
    expect(find.text('PRODUCTION'), findsOneWidget);
    // Should NOT show Extend 30d or Start Production (30d) while active
    expect(find.text('Extend 30d'), findsNothing);
    expect(find.text('Start Production (30d)'), findsNothing);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('UserCard shows Extend 30d button when production user has expired', (WidgetTester tester) async {
    final now = DateTime.now();
    final expiredProdUser = UserModel(
      id: 'expired_prod',
      pass: 'secret',
      currentDate: now.subtract(const Duration(days: 35)),
      expiryDate: now.subtract(const Duration(days: 5)),
      masterCode: 'MASTER_PIYUSH',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(
            user: expiredProdUser,
            onStartProduction: () {},
            onResetDeviceId: () {},
            onToggleStop: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('expired_prod'), findsOneWidget);
    expect(find.text('PRODUCTION EXPIRED'), findsOneWidget);
    // Should show Extend 30d when expired
    expect(find.text('Extend 30d'), findsOneWidget);
  });

  testWidgets('ConfirmationDialog closes properly when confirmed and invokes callback', (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dlgContext) => ConfirmationDialog(
                      title: 'Delete User',
                      message: 'Are you sure you want to delete "dori"?',
                      confirmText: 'Delete',
                      onConfirm: () {
                        confirmed = true;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete User'), findsOneWidget);
    expect(find.text('Are you sure you want to delete "dori"?'), findsOneWidget);

    // Tap Delete button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    // Dialog must be completely dismissed and confirmed callback executed
    expect(confirmed, isTrue);
    expect(find.text('Delete User'), findsNothing);
    expect(find.text('Are you sure you want to delete "dori"?'), findsNothing);
  });

  testWidgets('ConfirmationDialog closes properly when cancelled without invoking callback', (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dlgContext) => ConfirmationDialog(
                      title: 'Delete User',
                      message: 'Are you sure you want to delete "dori"?',
                      confirmText: 'Delete',
                      onConfirm: () {
                        confirmed = true;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete User'), findsOneWidget);

    // Tap Cancel button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Dialog must be dismissed and confirmed remains false
    expect(confirmed, isFalse);
    expect(find.text('Delete User'), findsNothing);
  });
}


