// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/call/screens/call_screen.dart';
import 'package:whatsapp_clone/models/call.dart';
import 'package:whatsapp_clone/models/group.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    fireStore: FirebaseFirestore.instance,
    fireAuth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth fireAuth;
  CallRepository({
    required this.fireStore,
    required this.fireAuth,
  });

  Stream<DocumentSnapshot> get callStream =>
      fireStore.collection('call').doc(fireAuth.currentUser!.uid).snapshots();

  void makeCall(
      BuildContext context, Call senderCallData, Call receiverCallData) async {
    try {
      await fireStore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await fireStore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
                channelId: senderCallData.callId,
                call: senderCallData,
                isGroupChat: false),
          ));
    } catch (e) {
      showSnackBar(context, "$e");
    }
  }

  void endCall(BuildContext context, String callerId, String receiverId) async {
    try {
      await fireStore.collection('call').doc(callerId).delete();
      await fireStore.collection('call').doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context, "$e");
    }
  }

  void makeGroupCall(
      BuildContext context, Call senderCallData, Call receiverCallData) async {
    try {
      await fireStore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      var groupSnapshot = await fireStore
          .collection('gorups')
          .doc(senderCallData.receiverId)
          .get();
      Group group = Group.fromMap(groupSnapshot.data()!);

      for (String id in group.membersId) {
        await fireStore
            .collection('call')
            .doc(id)
            .set(receiverCallData.toMap());
      }

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              channelId: senderCallData.callId,
              call: senderCallData,
              isGroupChat: true,
            ),
          ));
    } catch (e) {
      showSnackBar(context, "$e");
    }
  }

  void endGroupCall(
      BuildContext context, String callerId, String receiverId) async {
    try {
      await fireStore.collection('call').doc(callerId).delete();
      var groupSnapshot =
          await fireStore.collection('gorups').doc(receiverId).get();
      Group group = Group.fromMap(groupSnapshot.data()!);
      for (var id in group.membersId) {
        await fireStore.collection('call').doc(id).delete();
      }
    } catch (e) {
      showSnackBar(context, "$e");
    }
  }
}
