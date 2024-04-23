import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_image_gif.dart';

class SenderMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum messageType;
  final VoidCallback onRightSwipe;
  final String replyText;
  final String userName;
  final MessageEnum repliedMessageType;
  const SenderMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.messageType,
    required this.onRightSwipe,
    required this.replyText,
    required this.userName,
    required this.repliedMessageType,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = replyText.isNotEmpty;

    return SwipeTo(
      onRightSwipe: (details) => onRightSwipe(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: senderMessageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: messageType == MessageEnum.text
                      ? const EdgeInsets.only(
                          left: 10,
                          right: 30,
                          top: 5,
                          bottom: 20,
                        )
                      : const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 5,
                          bottom: 25,
                        ),
                  child: Column(
                    children: [
                      if (isReplying) ...[
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: backgroundColor.withOpacity(0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DisplayTextImageGif(
                            message: replyText,
                            messageType: repliedMessageType,
                          ),
                        ),
                      ],
                      DisplayTextImageGif(
                        message: message,
                        messageType: messageType,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 10,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
