import 'package:flutter/material.dart';
import 'carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:provider/provider.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

Future<void> main() async {
  runApp(StreamProvider(
      catchError: (_, error) => error.toString(),
      create: (context) => DVBI(endpointUrl: endpointUrl).getServiceStream(),
      initialData: const [],
      child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceElem>(
        builder: (context, ServiceElem service, child) => MyCarousel(items: [
              Image(
                  image: NetworkImage(
                service.logo.toString(),
              ))
            ]));
  }
}
