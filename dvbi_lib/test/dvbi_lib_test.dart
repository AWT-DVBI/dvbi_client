// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:dvbi_lib/dvbi_lib.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

Future<void> main() async {
  final dvbi = DVBI(endpointUrl: Uri.parse(endpointUrl));
  var services = dvbi.stream;

  var first = await services.first;

  if (first.contentGuideSourceElem?.scheduleInfoEndpoint != null) {
    var mytest = first.contentGuideSourceElem?.scheduleInfoEndpoint;

    var res2 = await dvbi.programScheduleInfoNowNext(
        mytest.toString(),
        first
            .uniqueIdentifier); //eig muss contentguideServiceRef hinzu //TODO zu serviceelement und dann abfrage wenn cgSr da ist dann vllt uId ersetzen oder bei abfrage ändern

    var res3 = await res2.first;

    print(res3.current.title);

    print(mytest);
  }

  print("----");

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(first);
  print(prettyprint);
  print("end");
}
