// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'video_carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

// We are using state management platform riverpod:
// https://riverpod.dev/de/docs/concepts/providers

final serviceProvider = StreamProvider.autoDispose((ref) async* {
  String data = await rootBundle.loadString("assets/services.xml");
  final dvbi = DVBI(data: data);

  ref.onDispose(() {
    // Schließt den stream, wenn der Zustand des Providers zerstört wird.
    dvbi.close();
  });

  await for (final serviceElem in dvbi.stream) {
    if (serviceElem.dashmpd == null) {
      continue;
    }
    yield serviceElem;
  }
});

final serivceListProvider = StreamProvider.autoDispose((ref) async* {
  final serviceStream = ref.watch(serviceProvider.stream);

  List<ServiceElem> videoList = const [];
  await for (final item in serviceStream) {
    videoList = [...videoList, item];
    yield videoList;
  }
});

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
