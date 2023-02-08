// ignore_for_file: depend_on_referenced_packages, unused_import, implementation_imports

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
      {Key? key,
      this.title = 'IPTV Player',
      required this.dvbi,
      required this.serviceElems,
      required this.startingChannel})
      : super(key: key);

  static const routeName = "IPTVPlayer";

  final String title;
  final DVBI dvbi;
  final List<ServiceElem> serviceElems;
  final int startingChannel;

  @override
  State<StatefulWidget> createState() {
    return _IPTVPlayerState();
  }
}

class VideoInfoWidget extends StatelessWidget {
  const VideoInfoWidget({required this.service, super.key});
  final ServiceElem service;
  @override
  Widget build(BuildContext context) {
    var s = service;
    String logoUrl = s.logo == null
        ? "https://docs.flutter.dev/assets/images/dash/dash-fainting.gif"
        : s.logo.toString();
    final notifier = Provider.of<PlayerNotifier>(context, listen: true);
    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
          alignment: Alignment.topCenter,
          child: ClipRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 0.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.network(
                    logoUrl,
                    errorBuilder: (context, exception, stackTrace) {
                      return Text('Your error widget...');
                    },
                  ),
                  const SizedBox(width: 60),
                  Text(s.serviceName,
                      style: Theme.of(context).textTheme.headline3)
                ],
              ),
            ),
          )),
    );
  }
}

class _IPTVPlayerState extends State<IPTVPlayer> {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;

  MyMaterialControls? videoControls;
  int? bufferDelay;
  late int currPlayIndex;
  late DVBI dvbi;
  late List<ServiceElem> serviceElems;

  @override
  void initState() {
    super.initState();
    dvbi = widget.dvbi;
    serviceElems = widget.serviceElems;
    currPlayIndex = widget.startingChannel;
    initializeEverything();
  }

  @override
  void dispose() {
    _videoPlayerController1?.dispose();

    _chewieController?.dispose();

    super.dispose();
  }

  Future<void> initializeEverything() async {
    videoControls = MyMaterialControls(
      showPlayButton: true,
      nextSrc: nextChannel,
      prevSrc: prevChannel,
    );
    await initializePlayer();
  }

  Future<void> initializePlayer() async {
    logger.d("Init video num $currPlayIndex");
    final source = serviceElems[currPlayIndex].dashmpd.toString();
    var newController = VideoPlayerController.network(source);

    if (_videoPlayerController1 != null) {
      newController.setVolume(_videoPlayerController1!.value.volume);
    }

    try {
      await newController.initialize();
    } catch (e, trace) {
      logger.d(e.toString());
      logger.e("Source: $source", e, trace);
    }
    if (newController.value.hasError) {
      await newController.dispose();
      newController = VideoPlayerController.network(
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
      try {
        await newController.initialize();
      } catch (e, trace) {
        logger.d("Back up video source failed as well");
      }
    }

    _videoPlayerController1 = newController;
    _createChewieController();
    setState(() {});
  }

  Widget videoPlaybackError(BuildContext context, String error) {
    return Row(children: [
      Expanded(
          child: SingleChildScrollView(child: Text("Playback error $error")))
    ]);
  }

  void _createChewieController() {
    final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Hello',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            TextSpan(
              text: ' from ',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            TextSpan(
              text: 'subtitles',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            )
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: 'Whats up? :)',
        // text: const TextSpan(
        //   text: 'Whats up? :)',
        //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
        // ),
      ),
    ];

    final chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1!,
      autoPlay: true,
      looping: true,
      isLive: true,
      allowFullScreen: true,
      overlay: VideoInfoWidget(service: serviceElems[currPlayIndex]),
      customControls: videoControls!,
      fullScreenByDefault: true,
      errorBuilder: videoPlaybackError,
      hideControlsTimer: const Duration(seconds: 1),
      subtitle: Subtitles(subtitles),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),

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

    _chewieController?.dispose();
    _chewieController = chewieController;
  }

  Future<void> nextChannel() async {
    await _videoPlayerController1!.dispose();
    currPlayIndex += 1;
    setState(() {});
    if (currPlayIndex >= serviceElems.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  Future<void> prevChannel() async {
    await _videoPlayerController1!.dispose();
    currPlayIndex -= 1;
    if (currPlayIndex < 0) {
      currPlayIndex = serviceElems.length - 1;
    }
    await initializePlayer();
  }

  Widget buildVideoPlayer() {
    final chewieController = _chewieController;

    if (chewieController != null) {
      return Chewie(
        controller: chewieController,
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: Center(child: buildVideoPlayer())),
        ],
      ),
    );
  }
}
