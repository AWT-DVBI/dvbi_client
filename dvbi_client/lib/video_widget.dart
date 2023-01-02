// ignore_for_file: unused_import, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';
import 'main.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:developer' as dev;
import 'package:collection/collection.dart';

final videoProvider =
    StreamProvider.autoDispose<Result<VideoPlayerController, String>>(
        (ref) async* {
  final serviceStream = ref.watch(serviceProvider.stream);

  await for (final item in serviceStream) {
    final controller = VideoPlayerController.network(item.dashmpd!.toString());

    try {
      await controller.initialize();
    } catch (e) {
      yield Error(e.toString());
    }

    yield Success(controller);
  }
});

final videoListProvider = StreamProvider.autoDispose((ref) async* {
  final videoStream = ref.watch(videoProvider.stream);

  List<Result<VideoPlayerController, String>> videoList = const [];
  await for (final item in videoStream) {
    videoList = [...videoList, item];
    yield videoList;
  }
});

final videoNotifierProvider = StateNotifierProvider.autoDispose<VideoNotifier,
    List<Result<VideoPlayerController, String>>>((ref) {
  final videoController = ref.watch(videoListProvider);

  return VideoNotifier(data: videoController);
});

class VideoNotifier
    extends StateNotifier<List<Result<VideoPlayerController, String>>> {
  VideoNotifier({data}) : super(data);

  void add(Result<VideoPlayerController, String> controller) {
    state = [...state, controller];
  }

  void play(int index) {
    state[index].tryGetSuccess()!.play();
  }

  void pause(int index) {
    state[index].tryGetSuccess()!.pause();
  }
}


// class VideoListWidget extends ConsumerWidget {
//   const VideoListWidget({super.key});

//   List<Widget> controllerToWid() {

//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final videoList = ref.watch(videoListProvider);

//     return videoList.when(data: (videoList) {
//       return videoList.map((controller) {
//         return Text("");
//       }).toList();
//     }, error: (error, stackTrace) => Text(error.toString()), loading: () => const CircularProgressIndicator())

  //   return controller.when(
  //       (controller) => Scaffold(
  //             body: Center(
  //               child: controller.value.isInitialized
  //                   ? AspectRatio(
  //                       aspectRatio: controller.value.aspectRatio,
  //                       child: VideoPlayer(controller),
  //                     )
  //                   : const CircularProgressIndicator(),
  //             ),
  //             floatingActionButton: FloatingActionButton(
  //               onPressed: () {
  //                 controller.value.isPlaying
  //                     ? controller.pause()
  //                     : controller.play();
  //               },
  //               child: Icon(
  //                 controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
  //               ),
  //             ),
  //           ),
  //       ((error) =>
  //           Scaffold(body: Center(child: Text("Controller error: $error")))));
  // }
//}
