// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:dvbi_lib/dvbi_lib.dart';

Future<void> main() async {
  final dvbi = DVBI(endpointUrl: endpointUrl);
  var services = dvbi.getServiceStream();

  var first = await services.first;

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(first);
  print(prettyprint);
  print("end");
}
