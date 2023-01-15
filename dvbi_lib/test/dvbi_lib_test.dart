// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:dvbi_lib/dvbi.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

Future<void> main() async {
  final dvbi = await DVBI.create(endpointUrl: Uri.parse(endpointUrl));
  var services = dvbi.stream;

  var first = await services.first;

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(first);
  print(prettyprint);
  print("end");
}
