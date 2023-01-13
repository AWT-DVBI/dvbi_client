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

typedef MyVideoController = Result<VideoPlayerController?, String>;

@immutable
class MyVideoData {
  final ServiceElem service;
  final MyVideoController video;
  final int id;

  const MyVideoData(
      {required this.service, required this.video, required this.id});

  MyVideoData copyWith(
      {ServiceElem? service, MyVideoController? video, int? id}) {
    return MyVideoData(
        service: service ?? this.service,
        video: video ?? this.video,
        id: id ?? this.id);
  }
}

class AsyncVideoDataNotifier
    extends AutoDisposeAsyncNotifier<List<MyVideoData>> {
  AsyncVideoDataNotifier() : super();

  Future<void> initialize(int id) async {
    if (!state.hasValue) {
      logger.e("Tried to init loading video with id: $id ");
      return;
    }

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      loggerNoStack.d("await initializing video: $id");

      final res = state.value!.map((data) async {
        if (data.id == id) {
          final controller =
              VideoPlayerController.network(data.service.dashmpd!.toString());

          try {
            await controller.initialize();
            return data.copyWith(video: Success(controller));
          } catch (e) {
            return data.copyWith(video: Error(e.toString()));
          }
        }
        return data;
      });

      loggerNoStack.d("Now starting video: $id");
      return Future.wait(res.toList());
    });
  }

  Future<void> deinit(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = state.value!.map((data) async {
        if (data.id == id) {
          await data.video.tryGetSuccess()!.dispose();
          return data.copyWith(video: const Success(null));
        }
        return data;
      });

      loggerNoStack.d("Uninit video id $id");
      return Future.wait(res.toList());
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
    loggerNoStack.i("Rebuilding list");
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
