import 'package:easycook/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Testing 2 field 1 button", (WidgetTester widgetTester) async {
    await widgetTester.pumpWidget(
      LoginPage(),
    );

    expect(find.byKey(const Key('emailTextField')), findsOneWidget);
    expect(find.byKey(const Key('passwordTextField')), findsOneWidget);
    expect(find.byKey(const Key('masukButton')), findsOneWidget);

    await widgetTester.pump();
  });
}
