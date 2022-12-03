import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';


class VideoApp extends StatelessWidget {
   final String url;
   const VideoApp({required this.url, Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    
    return FutureProvider(
      create: (_) => VideoPlayerController.network("")
       ..initialize(),
      initialData: [],
      child: 
      )
    ;};
  }



}

// /// Stateful widget to fetch and then display video content.
// class VideoApp extends StatefulWidget {
//   final String url;
//   const VideoApp({required this.url, Key? key}) : super(key: key);

//   @override
//   VideoAppState createState() => VideoAppState();
// }

// class VideoAppState extends State<VideoApp> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.url)
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _controller.value.isInitialized
//         ? AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           )
//         : Container();
//   }

//   @override
//   void dispose() {
//     super.dispose();

//     _controller.dispose();
//   }
// }
