// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/config/agora_config.dart';
import 'package:whatsapp_clone/features/call/controller/call_controller.dart';
import 'package:whatsapp_clone/models/call.dart';
import 'package:agora_uikit/agora_uikit.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const CallScreen({
    super.key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? agoraClient;
  // String baseUr = "https://whatsapp-clone-akk-0784166b3ed4.herokuapp.com";
  String baseUr = "https://flutter-twitch-server1.onrender.com";
  // String baseUr = "https://flutter-twitch-server-f5p6nahyh.vercel.app";

  bool showButtons = true;

  @override
  void initState() {
    agoraClient = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: baseUr,
      ),
    );

    initAgora();
    super.initState();
  }

  void initAgora() async {
    await agoraClient!.initialize();
  }

  void showOrHideButtons() {
    setState(() {
      showButtons = !showButtons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: agoraClient == null
            ? const Loader()
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AgoraVideoViewer(
                      client: agoraClient!,
                      layoutType: Layout.oneToOne,
                      enableHostControls: true,
                      showAVState: true,
                    ),
                  ),
                  InkWell(
                    onTap: () => showOrHideButtons(),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          bottom: !showButtons ? -500 : 0,
                          left: 0,
                          right: 0,
                          child: AgoraVideoButtons(
                            client: agoraClient!,
                            autoHideButtons: true,
                            autoHideButtonTime: 3,
                            disconnectButtonChild: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 35,
                              child: IconButton(
                                onPressed: () async {
                                  await agoraClient!.engine.leaveChannel();
                                  ref.read(callControllerProvider).endCall(
                                      context,
                                      widget.call.callerId,
                                      widget.call.receiverId);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.call_end),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
