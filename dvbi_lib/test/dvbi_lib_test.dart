import 'package:flutter_test/flutter_test.dart';

import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:io';

Future<void> main() async {
  print("hello");

  var t1 = ServiceListManager();
  print("object");
  await t1.getXmlStream();

  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
