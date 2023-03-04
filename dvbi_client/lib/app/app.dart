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
  // Dart constructor. Arguments are directly the variables defined below
  const IPTVPlayer(
      {Key? key, this.title = 'IPTV Player', this.dvbi, this.endpoint})
      : super(key: key);

  // Final means they can only be initialized once
  final String title;
  final DVBI? dvbi;
  final Uri? endpoint;

  // State Widgets need two objects. The first one doesn't hold state just propagates it.
  @override
  State<StatefulWidget> createState() {
    return _IPTVPlayerState();
  }
}

// Top bar stateless widget displaying the title and image of the current TV channel
class VideoInfoWidget extends StatelessWidget {
  const VideoInfoWidget({required this.service, super.key});
  final ServiceElem service;

  @override
  Widget build(BuildContext context) {
    final s = service;

    // A callback the rerenders the info object when a dependency variable changed value
    final notifier = Provider.of<PlayerNotifier>(context, listen: true);

    return AnimatedOpacity(
      // In this case if the hideStuff variable changes we make this widget visible or invisible
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
                  Image(image: NetworkImage(s.logo.toString())),
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

// This class actually holds the IPTVPlayer State
class _IPTVPlayerState extends State<IPTVPlayer> {
  // All state variables used
  VideoPlayerController?
      _videoPlayerController1; // Video player object displayer video (Exoplyer wrapper)
  ChewieController?
      _chewieController; // UI controller ontop of the video player
  MyMaterialControls?
      videoControls; // Our own custom UI that implements chewies interface to be displayed ontop of the video player
  int? bufferDelay;
  late DVBI dvbi; // DVB-I object and parser library
  late List<ServiceElem>
      serviceElems; // Parsed and filtered list of service elements
  int currPlayIndex =
      0; // Current playing video used as index into serviceElems List

  // State variables get initialized automatically here
  @override
  void initState() {
    super.initState();
    initializeEverything();
  }

  // And disposed automatically here
  @override
  void dispose() {
    _videoPlayerController1?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializeSources() async {
    // We start by initializing the DVBI object from our dvbi_lib library.
    if (widget.dvbi != null) {
      dvbi = widget.dvbi!;
    } else {
      // TODO: Catch failed to connect error
      dvbi = await DVBI.create(endpointUrl: widget.endpoint!);
    }

    // And filter out any tv channels without a Dash Mpd attribute
    serviceElems =
        dvbi.serviceElems.where((element) => element.dashmpd != null).toList();
  }

  void initializeEverything() async {
    // We initialize the MyMaterialControls overlay UI. Which handles user input
    // for channel switchting and muting and displays the overlay. Code for this overlay is in video_player_controls.dart
    videoControls = MyMaterialControls(
      showPlayButton: true,
      nextSrc: nextChannel,
      prevSrc: prevChannel,
    );
    await initializeSources();
    initializePlayer();
  }

  void initializePlayer() async {
    logger.d("Init video num $currPlayIndex");

    // We select the tv channel to display by indexing the service elements
    // with the currPlayIndex integer and get the DASH MPD Url
    final source = serviceElems[currPlayIndex].dashmpd.toString();

    // We then create a new Video Player object with the dash mpd url
    final newController = VideoPlayerController.network(source);

    // If there already is an old video player we copy the audio volume
    // to the new video player
    if (_videoPlayerController1 != null) {
      newController.setVolume(_videoPlayerController1!.value.volume);
    }

    // We copy a reference to the old controller
    final oldController = _videoPlayerController1;

    // Then we replace the global video player object with our new one
    _videoPlayerController1 = newController;

    // Afterwards we make sure to dispose the old video stream to free up memory
    // and not run into OUT OF MEMORY issues on constrained devices.
    await oldController?.dispose();

    // At the end we initialize the video player object to start streaming and displaying content.
    try {
      await newController.initialize();
    } catch (e, trace) {
      logger.e("Source: $source", e, trace);
    }

    // Now we (re)-create the video UI player controller overlay.
    _createChewieController();

    // And tell flutter to rerender this widget
    setState(() {});
  }

  // Function executed when video player encounters an error.
  // We can't (yet) recover from this as the channel selection UI is gone.
  Widget videoPlaybackError(BuildContext context, String error) {
    return Row(children: [
      Expanded(
          child: SingleChildScrollView(child: Text("Playback error $error")))
    ]);
  }

  // Creates a new chewie controller with the current video player object
  void _createChewieController() {
    // Dummy subtitles for the eventual subtitle feature.
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

    // We create a ChewieController for the video player ui and give it
    // the newly initialized video player object
    // and create a stateless VideoInfoWidget that dispalys the tv channel name and logo on top
    final chewieController = ChewieController(
      videoPlayerController:
          _videoPlayerController1!, // Reference to the video player
      autoPlay: true,
      looping: true,
      isLive: true,
      allowFullScreen: true,
      overlay: VideoInfoWidget(
          service: serviceElems[
              currPlayIndex]), // An overlay sitting in between the controls and the video player
      customControls: videoControls!,
      fullScreenByDefault: true,
      errorBuilder:
          videoPlaybackError, // A render callback used when the video player runs into an error
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
    );

    // We copy a reference to the old controller
    final oldController = _chewieController;

    // To then replace it with our newly created one
    _chewieController = chewieController;

    // We first dispose of the old controller
    oldController?.dispose();

    // We do this so the UI has a valid reference to a controller all the time
  }

  // Switches to the next channel and recreates all UI elements tied to switching
  void nextChannel() {
    _videoPlayerController1!.dispose();
    currPlayIndex += 1;
    if (currPlayIndex >= serviceElems.length) {
      currPlayIndex = 0;
    }
    initializePlayer();
  }

  // Switches to the previous channel and recreates all UI elements tied to switching
  void prevChannel() {
    _videoPlayerController1!.pause();
    currPlayIndex -= 1;
    if (currPlayIndex < 0) {
      currPlayIndex = serviceElems.length - 1;
    }
    initializePlayer();
  }

  // Extracted widget to a function for better readability
  // Just aligns the video player properly inside the App
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

  // Actual rendered Widget returned by IPTVPlayer object
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
