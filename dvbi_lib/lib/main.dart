// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:pretty_json/pretty_json.dart';

Future<void> main(List<String> args) async {
  Logger.root.level = Level.INFO;

  CommandRunner runner = CommandRunner('dvbip', "A DVB-I to JSON converter");
  runner.argParser.addOption("endpoint", abbr: "e");
  runner.argParser.addFlag("verbose", abbr: "v");
  ArgResults argResults = runner.parse(args);

  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  if (argResults["verbose"]) {
    Logger.root.level = Level.ALL;
  }

  if (argResults["endpoint"] == null) {
    runner.printUsage();
    exit(64);
  }

  Uri endpoint = Uri.parse(argResults["endpoint"]);

  final dvbi = DVBI(endpointUrl: endpoint);
  var services = dvbi.stream;

  /*
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  var serviceList = await services.toList();
  String prettyprint = encoder.convert(serviceList);
  print(prettyprint);
*/
  //test nowNext
  print("NowNext test");
  var resNowNext =
      await services.first.then((value) => value.programScheduleInfoNowNext());
  resNowNext.first
      .then((value) => print(prettyJson(value.current.toJson(), indent: 2)));
  //test detailed program info
  print("test detailed program info ");
  // test scheduling unixtime
  print("test scheduling unixtime");
}
