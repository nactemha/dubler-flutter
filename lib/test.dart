import 'package:flutter/material.dart';
import 'TestPageWidget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Test test testing', (WidgetTester tester) async {
    expect(true, isTrue);
  });
}
