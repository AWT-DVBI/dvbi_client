import 'package:dvbi_client/video_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart';

class ContentGuidePage extends ConsumerWidget {
  //why do the tutorials have this?
  const ContentGuidePage({Key? key}): super(key: key);
  static const routeName = "contentGuidePage";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceList = ref.watch(serivceListProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Content Guide Page"),
        leading: Container(),
        actions:  [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Browse Channels',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const VideoCarousel();
              }));
            },
            alignment: Alignment.center,
          ),
        ],
        backgroundColor:Colors.orange,
        foregroundColor: Colors.blueGrey,
      ),
          body: serviceList.when(
              data: (serviceList) {
                return ListView.builder(
                        itemCount: serviceList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Image.network(serviceList[index].logo.toString()),
                            title: Text(serviceList[index].serviceName),
                            onTap: () {
                              Navigator.pushNamed(context, 'videoCarousel', arguments: index);
                              // Navigate to the carousel and start playing the selected video
                              },
                          );
                          },
                      );
              },
    error: (error, stackTrace) => Text(error.toString()),
    loading: () => const CircularProgressIndicator()),
    );
  }
}