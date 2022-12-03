import 'package:flutter/material.dart';
import 'carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:provider/provider.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

Future<void> main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<DVBI>(create: (context) => DVBI(endpointUrl: endpointUrl)),
          StreamProvider(
              create: (context) =>
                  DVBI(endpointUrl: endpointUrl).getServiceStream(),
              initialData: const []),
        ],
        child: MaterialApp(
            title: 'Video Demo', home: MyCarousel(items: const [])));
  }
}
