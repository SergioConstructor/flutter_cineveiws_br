import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cineveiws_br/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title and login button are present.
    expect(find.text('CineViews BR'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields
  });
}
