// ignore_for_file: depend_on_referenced_packages, unused_import

import 'package:chewie/chewie.dart';
import 'package:dvbi_client/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:logger/logger.dart';
import 'package:dvbi_lib/dvbi.dart';
import 'package:dvbi_lib/service_elem.dart';
import 'package:result_type/result_type.dart';
import 'video_player_controls.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  late VideoPlayerValue _latestValue;
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
    _videoPlayerController1.dispose();

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
    _videoPlayerController1 = VideoPlayerController.network(
        serviceElems[currPlayIndex].dashmpd.toString());
    try {
      await _videoPlayerController1.initialize();
    } catch (e) {
      logger.e("Error initializing videoPlayer");
      setState(() {});
      return;
    }
    _createChewieController();
    setState(() {});
  }

  Widget videoPlaybackError(BuildContext context, String error) {
    return Row(
        children: [Expanded(child: SingleChildScrollView(child: Text(error)))]);
  }

  Widget videoInfoWidget() {
    return Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 1.0,
          heightFactor: 0.2,
          child: Container(
            color: Colors.lightBlue,
            child: Center(child: Text(currPlayIndex.toString())),
          ),
        ));
  }

  void _createChewieController() {
    final chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      isLive: true,
      allowFullScreen: true,
      overlay: videoInfoWidget(),
      customControls: MyMaterialControls(
        showPlayButton: true,
        nextSrc: nextChannel,
        prevSrc: prevChannel,
      ),
      fullScreenByDefault: true,
      errorBuilder: videoPlaybackError,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: nextChannel,
            iconData: Icons.live_tv_sharp,
            title: 'Next Channel',
          ),
          OptionItem(
            onTap: prevChannel,
            iconData: Icons.live_tv_sharp,
            title: 'Prev Channel',
          ),
        ];
      },

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
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= serviceElems.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  Future<void> prevChannel() async {
    await _videoPlayerController1.pause();
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
