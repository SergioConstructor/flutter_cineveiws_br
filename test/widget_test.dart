import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cineveiws_br/services/local_storage_service.dart';
import 'package:flutter_cineveiws_br/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final storageService = LocalStorageService();
    await storageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(storageService: storageService));

    // Verify that the title and login button are present.
    expect(find.text('CineViews BR'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields
  });
}
