import 'package:flutter/material.dart';
import 'carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
        create: (_) => ServiceListManager().transformXMLToServiceObjList(),
        initialData: const [],
        child: MaterialApp(
            title: 'Video Demo', home: MyCarousel(items: const [])));
  }
}
