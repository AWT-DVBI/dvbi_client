// ignore_for_file: unused_import, depend_on_referenced_packages

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:collection/collection.dart';
import 'main.dart';

class Page {
  int? prev;
  int curr;

  Page({required this.prev, required this.curr});
}

final pageNum = StateProvider<int>(((ref) => 0));

final carouselControllerProvider =
    StateNotifierProvider<CarouselNotifier, CarouselController>((ref) {
  return CarouselNotifier();
});

class CarouselNotifier extends StateNotifier<CarouselController> {
  CarouselNotifier() : super(CarouselController());

  Future<void> animateToPage(int page, {Duration? duration, Curve? curve}) {
    return state.animateToPage(page, duration: duration, curve: curve);
  }

  void jumpToPage(int page) {
    state.jumpToPage(page);
  }

  Future<void> nextPage({Duration? duration, Curve? curve}) {
    return state.nextPage(duration: duration, curve: curve);
  }

  Future<void> get onReady => state.onReady;

  Future<void> previousPage({Duration? duration, Curve? curve}) {
    return state.previousPage(duration: duration, curve: curve);
  }

  bool get ready => state.ready;

  void startAutoPlay() {
    state.startAutoPlay();
  }

  void stopAutoPlay() {
    state.stopAutoPlay();
  }
}

class VideoCarousel extends ConsumerWidget {
  // Arguments for widget
  const VideoCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CarouselController carControl = ref.watch(carouselControllerProvider);
    final videoList = ref.watch(videoListProvider);

    return Stack(
      children: videoList.when(
          data: (videoList) {
            final res = videoList.map((vidControl) {
              return vidControl.video.when(
                  (vidControl) => Scaffold(
                        body: Center(
                          child: vidControl.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: vidControl.value.aspectRatio,
                                  child: VideoPlayer(vidControl),
                                )
                              : const CircularProgressIndicator(),
                        ),
                        floatingActionButton: FloatingActionButton(
                          onPressed: () {
                            vidControl.value.isPlaying
                                ? vidControl.pause()
                                : vidControl.play();
                          },
                          child: Icon(
                            vidControl.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                  (error) => Row(children: [
                        Expanded(
                            child: SingleChildScrollView(child: Text(error)))
                      ]));
            }).toList();

            return [
              CarouselSlider(
                items: res,
                carouselController: carControl,
                options: CarouselOptions(
                  onPageChanged: (index, reason) {
                    ref.read(pageNum.notifier).state = index;
                  },
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 2.0,
                  initialPage: 0,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 0.2,
                  child: Container(
                      color: Colors.lightBlue,
                      child:
                          Center(child: Text(ref.watch(pageNum).toString()))),
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 32)),
                    onPressed: () {
                      carControl.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    },
                    child: const Icon(Icons.arrow_back_ios, size: 32),
                  )),
              Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 32)),
                    onPressed: () {
                      carControl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    },
                    child: const Icon(Icons.arrow_forward_ios, size: 32),
                  ))
            ];
          },
          error: (error, stackTrace) => [Text(error.toString())],
          loading: () => [const CircularProgressIndicator()]),
    );
  }
}
