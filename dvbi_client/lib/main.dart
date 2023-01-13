// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:dvbi_client/app/app.dart';

// globals
const String endpointUrl = "https://dvb-i.net/production/services.php/de";
var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

void main() {
  runApp(
    IPTVPlayer(
      endpoint: Uri.parse(endpointUrl),
    ),
  );
}
