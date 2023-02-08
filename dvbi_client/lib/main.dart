// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:dvbi_lib/service_elem.dart';
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

class Root extends StatefulWidget {
  final Uri endpoint;
  const Root({Key? key, required this.endpoint}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Root();
  }
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class _Root extends State<Root> {
  late Future<DVBI> dvbi;
  List<ServiceElem>? serviceElems;
  bool renderIPTV = false;
  int currPlayIndex = 0;
  @override
  void initState() {
    super.initState();
    dvbi = DVBI.create(endpointUrl: Uri.parse(widget.endpoint.toString()));
    dvbi.then((value) {
      setState(() {
        serviceElems = value.serviceElems
            .where((element) => element.dashmpd != null)
            .toList();
      });
    });
  }

  void onTapRender(int playIndex) {
    loggerNoStack.i("Pressed onTapRender");
    setState(() {
      renderIPTV = true;
      currPlayIndex = playIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: FutureBuilder<DVBI>(
            future: dvbi,
            builder: (BuildContext context, AsyncSnapshot<DVBI> snapshot) {
              if (snapshot.hasData) {
                if (renderIPTV) {
                  return IPTVPlayer(
                      dvbi: snapshot.data!,
                      serviceElems: serviceElems!,
                      startingChannel: currPlayIndex);
                } else {
                  return Scaffold(
                      body: ContentGuidePage(
                    dvbi: snapshot.data,
                    onTapRender: onTapRender,
                    serviceElems: serviceElems!,
                  ));
                }
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner
              return const CircularProgressIndicator();
            },
          ),
        ));
  }
}
