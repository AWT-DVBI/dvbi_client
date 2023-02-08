// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:dvbi_lib/dvbi.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:dvbi_client/app/app.dart';

import 'app/ContentGuidePage.dart';
import 'app/theme.dart';

// globals
const String endpointUrl = "https://dvb-i.net/production/services.php/de";
var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

void main() {
  runApp(
    Root(
      endpoint: Uri.parse(endpointUrl),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class Root extends StatelessWidget {

  Root(
      {Key? key, required this.endpoint})
      : super(key: key);

  final Uri endpoint;
  final Future<DVBI> dvbi =  DVBI.create(endpointUrl: Uri.parse(endpointUrl));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home:  Scaffold(
        body: FutureBuilder<DVBI>(
        future: dvbi,
        builder: (BuildContext context, AsyncSnapshot<DVBI> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: ContentGuidePage(dvbi: snapshot.data));
      }
      else if (snapshot.hasError) {
        return Text("${snapshot.error}");
      }
      // By default, show a loading spinner
      return const CircularProgressIndicator();
    },
    ),
    )
    );
  }
}
