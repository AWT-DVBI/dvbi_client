import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MyCarousel extends StatelessWidget {
  final CarouselController buttonCarouselController = CarouselController();

  // Arguments for widget
  final List<Widget>? items;
  MyCarousel({required this.items, super.key});

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        CarouselSlider(
          items: items,
          carouselController: buttonCarouselController,
          options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
            initialPage: 2,
          ),
        ),
        ElevatedButton(
          onPressed: () => buttonCarouselController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear),
          child: const Text('→'),
        )
      ]);
}
