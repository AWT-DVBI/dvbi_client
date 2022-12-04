import 'package:flutter/material.dart';
import 'carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";
// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
final helloWorldProvider = Provider((_) => 'Hello world');

// We are using state management platform riverpod:
// https://riverpod.dev/de/docs/concepts/providers

final serviceProvider = StreamProvider.autoDispose((ref) {
  final dvbi = DVBI(endpointUrl: Uri.parse(endpointUrl));

  ref.onDispose(() {
    // Schließt den stream, wenn der Zustand des Providers zerstört wird.
    dvbi.close();
  });

  return dvbi.stream;
});

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ServiceElem> serviceStream = ref.watch(serviceProvider);

    return MaterialApp(
        home: MyCarousel(
            items: serviceStream.when(
                data: (item) =>
                    ([Image(image: NetworkImage(item.logo!.toString()))]),
                error: (e, st) => [Center(child: Text(e.toString()))],
                loading: () =>
                    [const Center(child: CircularProgressIndicator())])));
  }
}
