// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:pretty_json/pretty_json.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

Future<void> main() async {
  final dvbi = DVBI(endpointUrl: Uri.parse(endpointUrl));
  var services = dvbi.stream;

  //list of services
  var first = await services.first;

  //abfrage test für schedule info
  if (first.contentGuideSourceElem?.scheduleInfoEndpoint != null) {
    var mytest = first.contentGuideSourceElem?.scheduleInfoEndpoint;

    var res2 = await dvbi.programScheduleInfoNowNext(
        mytest.toString(),
        first
            .uniqueIdentifier); //eig muss contentguideServiceRef hinzu //TODO zu serviceelement und dann abfrage wenn cgSr da ist dann vllt uId ersetzen oder bei abfrage ändern

    var res3 = await res2.first;

    var json1 = res3.current.toJson();

    print(prettyJson(json1, indent: 2));

    //abfrage test für program info

  }

  print("----");

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(first);
  print(prettyprint);
  print("end");
}
