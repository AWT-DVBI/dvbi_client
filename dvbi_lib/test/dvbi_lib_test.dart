// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_test/flutter_test.dart';

import 'package:dvbi_lib/dvbi_lib.dart';

Future<void> main() async {
  print("hello");

  var t1 = ServiceListManager();
  await t1.testerFun();

  print(await t1.getArdLiveStream());

  var t2 = ServiceObject(
      "serviceName", "mpdURI", "channelBannerURI", PlayListObject());
}
