import 'package:carousel_slider/carousel_slider.dart';
import 'package:dvbi_client/main.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final carouselControllerProvider = Provider((ref) {
  CarouselController buttonCarouselController = CarouselController();
  return buttonCarouselController;
});
final carouselStateProvider = StateProvider((ref) => null);


class MyCarousel extends ConsumerWidget {
  // Arguments for widget
  final List<Widget> items;

  MyCarousel({required this.items, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CarouselController controller = ref.watch(carouselControllerProvider);
    return Column(children: <Widget>[
      CarouselSlider(
        items: items,
        carouselController: controller,
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 2.0,
          initialPage: 0,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32)),
            onPressed: () =>
                controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear),
            child: const Icon(Icons.arrow_back_ios, size: 32),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32)),
            onPressed: () =>
                controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear),
            child: const Icon(Icons.arrow_forward_ios, size: 32),
          )
        ],
      )
    ]);
  }
}