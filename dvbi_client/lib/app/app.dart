// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:dvbi_client/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:logger/logger.dart';
import 'package:dvbi_lib/dvbi_lib.dart';

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

class _IPTVPlayerState extends State<IPTVPlayer> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  ChewieController? _chewieController;
  int? bufferDelay;
  late DVBI dvbi;
  late List<ServiceElem> serviceElems;

  @override
  void initState() {
    super.initState();
    initializeEverything();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializeSources() async {
    if (widget.dvbi != null) {
      dvbi = widget.dvbi!;
    } else {
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
    _videoPlayerController1 = VideoPlayerController.network(
        serviceElems[currPlayIndex].dashmpd.toString());
    _videoPlayerController2 = VideoPlayerController.network(
        serviceElems[currPlayIndex].dashmpd.toString());
    await Future.wait([
      _videoPlayerController1.initialize(),
      _videoPlayerController2.initialize()
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      isLive: true,
      fullScreenByDefault: true,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: toggleVideo,
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },

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

      hideControlsTimer: const Duration(seconds: 3),

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
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= serviceElems.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: AppTheme.dark.copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Chewie(
                        controller: _chewieController!,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Loading'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
