import 'package:flutter_test/flutter_test.dart';

import 'package:dvbi_lib/dvbi_lib.dart';

void main() {
  print("hello");

  var t1 = XmlParser();
  print(t1.myXml);
  t1.xmlHandler();
  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
