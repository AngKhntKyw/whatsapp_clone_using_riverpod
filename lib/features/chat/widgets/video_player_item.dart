import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerController cachedVideoPlayerController;
  bool isPlaying = false;

  @override
  void initState() {
    cachedVideoPlayerController =
        CachedVideoPlayerController.network(widget.videoUrl)
          ..initialize().then((value) {
            cachedVideoPlayerController.setVolume(1);
          });
    super.initState();
  }

  @override
  void dispose() {
    cachedVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedVideoPlayer(cachedVideoPlayerController),
          IconButton(
            onPressed: () async {
              isPlaying
                  ? await cachedVideoPlayerController.pause()
                  : await cachedVideoPlayerController.play();
              setState(() {
                isPlaying = !isPlaying;
              });
            },
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
          )
        ],
      ),
    );
  }
}
