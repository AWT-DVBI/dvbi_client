// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dvbi_client/app/app.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String data = await rootBundle.loadString("assets/services.xml");
    await tester.pumpWidget(IPTVPlayer(
      dvbi: DVBI(data: data),
    ));
  });
}
