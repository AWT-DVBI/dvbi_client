// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:dvbi_lib/dvbi.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:dvbi_client/app/app.dart';

// globals
const String endpointUrl = "https://dvb-i.net/production/services.php/de";
var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

// Application start
void main() {
  runApp(
    // Our DVB-I Player object. Requires the endpoint URL.
    IPTVPlayer(
      endpoint: Uri.parse(endpointUrl),
    ),
  );
}
