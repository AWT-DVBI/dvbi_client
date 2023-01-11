// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';
import 'main.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:developer' as dev;
import 'package:collection/collection.dart';

@immutable
class MyVideoData {
  final int id;
  final ServiceElem service;
  final Result<VideoPlayerController, String> video;

  const MyVideoData(
      {required this.service, required this.video, required this.id});

  MyVideoData copyWith(
      {int? id,
      ServiceElem? service,
      Result<VideoPlayerController, String>? video}) {
    return MyVideoData(
        service: service ?? this.service,
        video: video ?? this.video,
        id: id ?? this.id);
  }
}

@immutable
class InitializedVideos {
  final List<MyVideoData> videoList;
  final List<Int> initVideos;

  const InitializedVideos({required this.initVideos, required this.videoList});

  InitializedVideos copyWith(
      {List<Int>? initVideos, List<MyVideoData>? videoList}) {
    return InitializedVideos(
        initVideos: initVideos ?? this.initVideos,
        videoList: videoList ?? this.videoList);
  }
}

final videoProvider = StreamProvider.autoDispose<MyVideoData>((ref) async* {
  final serviceStream = ref.watch(streamServiceElemsProvider);

  int id = 0;
  await for (final item in serviceStream) {
    final controller = VideoPlayerController.network(item.dashmpd!.toString());
    id += 1;

    yield MyVideoData(video: Success(controller), service: item, id: id);
  }
});

final videoListProvider = StreamProvider.autoDispose((ref) async* {
  final videoStream = ref.watch(videoProvider.stream);

  List<MyVideoData> videoList = const [];
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

class VideoNotifier extends StateNotifier<List<MyVideoData>> {
  VideoNotifier({data}) : super(data);

  void add(MyVideoData controller) {
    state = [...state, controller];
  }

  void setError(int id, String error) {
    state = [
      for (final data in state)
        if (data.id == id) data.copyWith(video: Error(error)) else data
    ];
  }

  Future<void> initVideos(int id) async {
    final futureList = state.map((data) async {
      if (data.id == id) {
        try {
          await data.video.tryGetSuccess()!.initialize();
          return data;
        } catch (e) {
          data.copyWith(video: Error(e.toString()));
        }
      }
      return data;
    });

    final List<MyVideoData> list = [];
    for (final item in futureList) {
      list.add(await item);
    }
    state = list;
  }

  void remove(int id) {
    state = [
      for (final data in state)
        if (data.id != id) data
    ];
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
