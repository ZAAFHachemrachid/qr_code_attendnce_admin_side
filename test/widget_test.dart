import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_attendnce_admin_side/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MainApp(),
      ),
    );

    expect(find.text('Overview'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
