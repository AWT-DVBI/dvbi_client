// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';
import 'main.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:developer' as dev;

// Code generation
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'video_widget.freezed.dart';

@freezed
class MyVideoData with _$MyVideoData {
  const factory MyVideoData(
      {required ServiceElem service,
      required Result<VideoPlayerController, String> video,
      required int id}) = _MyVideoData;
}

@freezed
class InitializedVideos with _$InitializedVideos {
  const factory InitializedVideos(
      {required List<int> initVideos,
      required List<MyVideoData> videoList}) = _InitializedVideos;
}

final videoListProvider = StreamProvider.autoDispose((ref) async* {
  final serviceStream = ref.watch(serviceElemsProvider.stream);

  int id = 0;
  List<MyVideoData> videoList = const [];
  await for (final item in serviceStream) {
    final controller = VideoPlayerController.network(item.dashmpd!.toString());
    Result<VideoPlayerController, String> res = Success(controller);

    if (id < 3) {
      try {
        await controller.initialize();
      } catch (e) {
        res = Error(e.toString());
      }
    }

    final videoData = MyVideoData(video: res, service: item, id: id);
    videoList = [...videoList, videoData];
    yield videoList;
    id += 1;
  }
});
