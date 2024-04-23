import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/features/chat/widgets/video_player_item.dart';

class DisplayTextImageGif extends StatelessWidget {
  final String message;
  final MessageEnum messageType;
  const DisplayTextImageGif({
    super.key,
    required this.message,
    required this.messageType,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();

    return messageType == MessageEnum.text
        ? Text(message)
        : messageType == MessageEnum.audio
            ? StatefulBuilder(
                builder: (context, setState) {
                  return IconButton(
                    constraints: const BoxConstraints(minWidth: 100),
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await audioPlayer.play(UrlSource(message));
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                    icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle),
                  );
                },
              )
            : messageType == MessageEnum.video
                ? VideoPlayerItem(videoUrl: message)
                : CachedNetworkImage(
                    cacheKey: message,
                    imageUrl: message,
                  );
  }
}
