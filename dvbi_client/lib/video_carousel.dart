// ignore_for_file: unused_import, depend_on_referenced_packages

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';

import 'main.dart';

// Code generation
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'video_carousel.freezed.dart';

@freezed
class Page with _$Page {
  const factory Page({required List<int> prev, required int curr}) = _Page;
}

class PageNotifier extends StateNotifier<Page> {
  PageNotifier() : super(const Page(curr: 0, prev: []));

  int get currPage {
    return state.curr;
  }

  void setCurrPage(int curr) {
    var sub = [curr];
    if (state.prev.length > 2) {
      sub = state.prev.reversed.toList().sublist(2) + [curr];
    }
    state = state.copyWith(prev: sub, curr: curr);
  }
}

final getPageProvider = StateNotifierProvider<PageNotifier, Page>((ref) {
  return PageNotifier();
});

final carouselControllerProvider = Provider<CarouselController>((ref) {
  return CarouselController();
});

class VideoCarousel extends ConsumerWidget {
  // Arguments for widget
  const VideoCarousel({super.key});

  List<Widget> createVideoPanes(List<MyVideoData> videoList) {
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
                    vidControl.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
              ),
          (error) => Row(children: [
                Expanded(child: SingleChildScrollView(child: Text(error)))
              ]));
    }).toList();

    return res;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CarouselController carControl = ref.watch(carouselControllerProvider);
    final videoList = ref.watch(videoListProvider);

    return Stack(children: [
      CarouselSlider(
        items: videoList.when(
            data: (videoList) => createVideoPanes(videoList),
            error: (error, b) => [
                  Expanded(
                      child:
                          SingleChildScrollView(child: Text(error.toString())))
                ],
            loading: () => [const CircularProgressIndicator()]),
        carouselController: carControl,
        options: CarouselOptions(
          onPageChanged: (index, reason) {
            ref.read(getPageProvider.notifier).setCurrPage(index);
          },
          onScrolled: (value) {},
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
              child: Center(
                  child: Text(ref.watch(getPageProvider).curr.toString()))),
        ),
      ),
      Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32)),
            onPressed: () {
              carControl.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear);
            },
            child: const Icon(Icons.arrow_forward_ios, size: 32),
          ))
    ]);
  }
}
