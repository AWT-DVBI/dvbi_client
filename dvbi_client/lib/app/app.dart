// ignore_for_file: depend_on_referenced_packages, unused_import

import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:dvbi_client/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:logger/logger.dart';
import 'package:dvbi_lib/dvbi.dart';
import 'package:dvbi_lib/service_elem.dart';
import 'package:result_type/result_type.dart';
import 'video_player_controls.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

var logger = Logger(printer: PrettyPrinter());
var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

class IPTVPlayer extends StatefulWidget {
  const IPTVPlayer(
      {Key? key, this.title = 'IPTV Player', this.dvbi, this.endpoint})
      : super(key: key);

  final String title;
  final DVBI? dvbi;
  final Uri? endpoint;

  @override
  State<StatefulWidget> createState() {
    return _IPTVPlayerState();
  }
}

class VideoInfoWidget extends StatefulWidget {
  const VideoInfoWidget({required this.service, super.key});

  final ServiceElem service;

  @override
  State<StatefulWidget> createState() {
    return _VideoInfoWidget();
  }
}

class _VideoInfoWidget extends State<VideoInfoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final notifier = Provider.of<PlayerNotifier>(context, listen: true);

    return AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 0.2,
            child: Row(
              children: [
                Image(image: NetworkImage(s.logo.toString())),
                const SizedBox(width: 30),
                Text(s.serviceName, textScaleFactor: 2.5)
              ],
            ),
          ),
        ));
  }
}

class _IPTVPlayerState extends State<IPTVPlayer> {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;

  int? bufferDelay;
  late DVBI dvbi;
  late List<ServiceElem> serviceElems;
  int currPlayIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeEverything();
  }

  @override
  void dispose() {
    _videoPlayerController1?.dispose();

    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializeSources() async {
    if (widget.dvbi != null) {
      dvbi = widget.dvbi!;
    } else {
      // TODO: Catch failed to connect error
      dvbi = await DVBI.create(endpointUrl: widget.endpoint!);
    }

    serviceElems =
        dvbi.serviceElems.where((element) => element.dashmpd != null).toList();
  }

  Future<void> initializeEverything() async {
    await initializeSources();
    await initializePlayer();
  }

  Future<void> initializePlayer() async {
    logger.d("Init video num $currPlayIndex");
    final newController = VideoPlayerController.network(
        serviceElems[currPlayIndex].dashmpd.toString());

    if (_videoPlayerController1 != null) {
      newController.setVolume(_videoPlayerController1!.value.volume);
    }

    _videoPlayerController1 = newController;

    await _videoPlayerController1!.initialize();

    _createChewieController();
    setState(() {});
  }

  Widget videoPlaybackError(BuildContext context, String error) {
    return Row(
        children: [Expanded(child: SingleChildScrollView(child: Text(error)))]);
  }

  void _createChewieController() {
    final chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1!,
      autoPlay: true,
      looping: true,
      isLive: true,
      allowFullScreen: true,
      overlay: VideoInfoWidget(service: serviceElems[currPlayIndex]),
      customControls: MyMaterialControls(
        showPlayButton: true,
        nextSrc: nextChannel,
        prevSrc: prevChannel,
      ),
      fullScreenByDefault: true,
      errorBuilder: videoPlaybackError,

      hideControlsTimer: const Duration(seconds: 1),

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );

    _chewieController = chewieController;
  }

  Future<void> nextChannel() async {
    await _videoPlayerController1!.dispose();
    currPlayIndex += 1;
    if (currPlayIndex >= serviceElems.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  Future<void> prevChannel() async {
    await _videoPlayerController1!.pause();
    currPlayIndex -= 1;
    if (currPlayIndex < 0) {
      currPlayIndex = serviceElems.length - 1;
    }
    await initializePlayer();
  }

  Widget buildVideoPlayer() {
    final chewieController = _chewieController;
    return chewieController != null &&
            chewieController.videoPlayerController.value.isInitialized
        ? Chewie(
            controller: chewieController,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: AppTheme.dark,
      home: Column(
        children: <Widget>[
          Expanded(child: Center(child: buildVideoPlayer())),
        ],
      ),
    );
  }
}
