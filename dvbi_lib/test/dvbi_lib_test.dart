import 'package:flutter_test/flutter_test.dart';

import 'package:dvbi_lib/dvbi_lib.dart';

Future<void> main() async {
  print("hello");

  var t1 = ServiceListManager();
  await t1.testerFun();

  var t2 = ServiceObject(
      "serviceName", "mpdURI", "channelBannerURI", PlayListObject());

  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
