// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dvbi_lib/dvbi.dart';
import 'dart:io';
import 'package:logging/logging.dart';

final Logger log = Logger("main");

Future<void> main(List<String> args) async {
  Logger.root.level = Level.INFO;

  CommandRunner runner = CommandRunner('dvbip', "A DVB-I to JSON converter");
  runner.argParser.addOption("endpoint", abbr: "e");
  //runner.argParser.addFlag("scheduleInfo", abbr: "si");
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

  final dvbi = await DVBI.create(endpointUrl: endpoint);
  var serviceList = dvbi.serviceElems;

  // await for (final service in dvbi.stream) {
  //   log.fine("Init ${service.serviceName}");
  //   await service.scheduleInfoAsync;
  //   serviceList.add(service);
  // }
  try {
    await Future.wait(serviceList.map((e) => e.scheduleInfo()));
  } catch (e) {
    print(e.toString());
  }

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(serviceList);
  print(prettyprint);
}
