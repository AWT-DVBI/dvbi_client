// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:async';
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

typedef MyVideoController = Result<VideoPlayerController?, String>;

@freezed
class MyVideoData with _$MyVideoData {
  const factory MyVideoData(
      {required ServiceElem service,
      required MyVideoController video,
      required int id}) = _MyVideoData;
}

class AsyncVideoDataNotifier
    extends AutoDisposeAsyncNotifier<List<MyVideoData>> {
  AsyncVideoDataNotifier() : super();

  Future<void> initialize(int id) async {
    if (!state.hasValue) {
      logger.e("Tried to init loading video with id: $id ");
      return;
    }

    final data = state.value!;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      logger.d("await initializing video: $id");

      final controller =
          VideoPlayerController.network(data[id].service.dashmpd!.toString());

      try {
        await controller.initialize();
        data[id] = data[id].copyWith(video: Success(controller));
      } catch (e) {
        data[id] = data[id].copyWith(video: Error(e.toString()));
      }

      logger.d("Now starting video: $id");
      return data;
    });
  }

  Future<void> deinit(int id) async {
    var data = state.value!;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await data[id].video.tryGetSuccess()!.dispose();
      data[id] = data[id].copyWith(video: const Success(null));

      return data;
    });
  }

  MyVideoController getController(int id) {
    return state.value!.firstWhere((element) => element.id == id).video;
  }

  Future<List<MyVideoData>> _mybuild(List<ServiceElem> serviceElems) async {
    int id = 0;
    List<MyVideoData> videoList = [];
    for (final item in serviceElems) {
      if (item.dashmpd == null) {
        continue;
      }
      // final controller =
      //     VideoPlayerController.network(item.dashmpd!.toString());
      // MyVideoController res = Success(controller);

      final videoData =
          MyVideoData(video: const Success(null), service: item, id: id);
      videoList.add(videoData);
      id += 1;
    }
    return videoList;
  }

  @override
  FutureOr<List<MyVideoData>> build() async {
    final serviceStream = await ref.watch(dvbiProvider.future);

    return _mybuild(serviceStream);
  }
}

final asyncVideoDataProvider = AsyncNotifierProvider.autoDispose<
    AsyncVideoDataNotifier, List<MyVideoData>>(() {
  AsyncVideoDataNotifier videoList = AsyncVideoDataNotifier();
  return videoList;
});
