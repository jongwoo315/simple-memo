import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_memo/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app launches with a Scaffold
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('FAB button exists for adding memo', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify FAB exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
