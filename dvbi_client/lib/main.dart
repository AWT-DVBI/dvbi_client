import 'package:flutter/material.dart';
import 'carousel.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";
// We are using state management platform riverpod:
// https://riverpod.dev/de/docs/concepts/providers

final serviceListProvider = FutureProvider((ref) async {
  final dvbi = DVBI(endpointUrl: Uri.parse(endpointUrl));
  List<ServiceElem> services = await dvbi.serviceElems;
  return services;
});


final streamProvider = StreamProvider.autoDispose((ref) {
  final dvbi = DVBI(endpointUrl: Uri.parse(endpointUrl));

  ref.onDispose(() {
    // Schließt den stream, wenn der Zustand des Providers zerstört wird.
    dvbi.close();
  });

  return dvbi.stream;
});

class ServicesNotifier extends StateNotifier<List<ServiceElem>> {
  // We initialize the list of todos to an empty list
  ServicesNotifier() : super(const <ServiceElem>[]);

  // Let's allow the UI to add todos.
  void addService(List<ServiceElem> service) {
    print("adding Service");
    // Since our state is immutable, we are not allowed to do `state.add(todo)`.
    // Instead, we should create a new list of todos which contains the previous
    // items and the new one.
    // Using Dart's spread operator here is helpful!
    state = [...state, ...service];
    // No need to call "notifyListeners" or anything similar. Calling "state ="
    // will automatically rebuild the UI when necessary.
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final servicesProvider = StateNotifierProvider.autoDispose<ServicesNotifier, List<ServiceElem>>((ref) {
  final services = ServicesNotifier();
  final AsyncValue<ServiceElem> service = ref.watch(streamProvider);
  service.when(
    loading: () => { print("loading service element")},
    error: (error, stack) => print(stack),
    data: (service) => services.addService([service]),
  );
  return services;
});

void main() {
  //final dvbi = DVBI(endpointUrl: Uri.parse(endpointUrl));
  //dvbi.stream.forEach((element) { print(element);});
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
    print("building myApp");
    //List<ServiceElem> services = ref.watch(servicesProvider);
    AsyncValue<List<ServiceElem>> serviceStream = ref.watch(serviceListProvider);
    return MaterialApp(
        home: MyCarousel(
            items: serviceStream.when(
                data: (services) {
                  return services.map((service) => Image(image: NetworkImage(service.logo!.toString()))).toList();
                },
                error: (e, st) => [Center(child: Text(e.toString()))],
                loading: () =>
                    [const Center(child: CircularProgressIndicator())])));
  }
}
