import 'dart:convert';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:io';

Future<void> main(List<String> args) async {
  CommandRunner runner = CommandRunner('dvbip', "A DVB-I to JSON converter");
  runner.argParser.addOption("endpoint", abbr: "e");
  ArgResults argResults = runner.parse(args);

  if (argResults["endpoint"] == null) {
    runner.printUsage();
    exit(64);
  }

  Uri endpoint = Uri.parse(argResults["endpoint"]);

  final dvbi = DVBI(endpointUrl: endpoint);
  var services = dvbi.stream;

  var first = await services.first;

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(first);
  print(prettyprint);
}
