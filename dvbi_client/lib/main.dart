// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'video_carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
// Code generation
import 'package:flutter/foundation.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

final dvbiProvider = FutureProvider.autoDispose((ref) async {
  //String data = await rootBundle.loadString("assets/services.xml");

  final dvbi = await DVBI().initialize(endpointUrl: Uri.parse(endpointUrl));

  return dvbi.serviceElems;
});

var logger = Logger(printer: PrettyPrinter());

var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(home: VideoCarousel());
  }
}
