// ignore_for_file: unused_import, depend_on_referenced_packages

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';

import 'main.dart';

import 'package:logger/logger.dart';

@immutable
class MyPage {
  const MyPage({required this.prev, required this.curr});

  final int? prev;
  final int curr;

  MyPage copyWith({int? prev, int? curr}) {
    return MyPage(curr: curr ?? this.curr, prev: prev ?? this.prev);
  }
}

class PageNotifier extends AsyncNotifier<MyPage> {
  PageNotifier() : super();

  @override
  Future<MyPage> build() async {
    const page = MyPage(prev: null, curr: 0);
    loggerNoStack.i("Rebuilding mypage");
    return Future.value(page);
  }

  int get currPage {
    return state.value!.curr;
  }

  Future<void> setCurrPage(int curr) async {
    // final List<int> sub;
    // if (state.prev.length > 1) {
    //   sub = state.prev.sublist(1, 2);
    //   ref.read(asyncVideoDataProvider.notifier).deinit(state.prev.first);
    // } else {
    //   sub = state.prev + [state.curr];
    // }
    var data = state.value!;

    state = await AsyncValue.guard(() async {
      // await ref.read(asyncVideoDataProvider.notifier).deinit(data.curr);
      await ref.read(asyncVideoDataProvider.notifier).initialize(curr);
      return data.copyWith(prev: data.curr, curr: curr);
    });
  }
}

final getPageProvider = AsyncNotifierProvider<PageNotifier, MyPage>(() {
  return PageNotifier();
});

final carouselControllerProvider = Provider<CarouselController>((ref) {
  return CarouselController();
});

class VideoCarousel extends ConsumerWidget {
  // Arguments for widget
  const VideoCarousel({super.key});

  bool isInitialized(VideoPlayerController? controller) {
    if (controller == null || controller.value.isInitialized == false) {
      return false;
    }

    return true;
  }

  List<Widget> createVideoPanes(List<MyVideoData> videoDataList) {
    final res = videoDataList.map((myVideoData) {
      return myVideoData.video.when(
          (controller) => Scaffold(
                body: Center(
                  child: isInitialized(controller)
                      ? AspectRatio(
                          aspectRatio: controller!.value.aspectRatio,
                          child: VideoPlayer(controller),
                        )
                      : const CircularProgressIndicator(),
                ),
                floatingActionButton: isInitialized(controller)
                    ? FloatingActionButton(
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        },
                        child: Icon(
                          controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      )
                    : null,
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
    final asyncList = ref.watch(asyncVideoDataProvider);
    final page = ref.watch(getPageProvider);

    return Stack(children: [
      CarouselSlider(
        items: asyncList.when(
            data: (videoList) => createVideoPanes(videoList),
            error: (error, b) => [
                  Row(children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: Text(error.toString())))
                  ])
                ],
            loading: () => [const Center(child: CircularProgressIndicator())]),
        carouselController: carControl,
        options: CarouselOptions(
          onPageChanged: (index, reason) async {
            loggerNoStack.i("onPageChanged index: $index, reason: $reason");
            await ref.read(getPageProvider.notifier).setCurrPage(index);
          },
          //  onScrolled: (value) {},
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
                  child: page.value != null
                      ? Text(page.value!.curr.toString())
                      : const Text("Loading"))),
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
