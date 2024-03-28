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
    return messageType == MessageEnum.text
        ? Text(message)
        : messageType == MessageEnum.image
            ? CachedNetworkImage(
                cacheKey: message,
                imageUrl: message,
              )
            : VideoPlayerItem(videoUrl: message);
  }
}
