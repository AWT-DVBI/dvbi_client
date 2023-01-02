// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:multiple_result/multiple_result.dart';
import 'main.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:developer' as dev;

// class VideoWidget extends ConsumerWidget {
//   final int index;
//   const VideoWidget({required this.index, super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return controller.when(
//         (controller) => Scaffold(
//               body: Center(
//                 child: controller.value.isInitialized
//                     ? AspectRatio(
//                         aspectRatio: controller.value.aspectRatio,
//                         child: VideoPlayer(controller),
//                       )
//                     : const CircularProgressIndicator(),
//               ),
//               floatingActionButton: FloatingActionButton(
//                 onPressed: () {
//                   controller.value.isPlaying
//                       ? controller.pause()
//                       : controller.play();
//                 },
//                 child: Icon(
//                   controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                 ),
//               ),
//             ),
//         ((error) =>
//             Scaffold(body: Center(child: Text("Controller error: $error")))));
//   }
// }
