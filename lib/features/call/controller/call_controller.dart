// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/call/repository/call_repository.dart';
import '../../../models/call.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
      callRepository: callRepository,
      ref: ref,
      fireAuth: FirebaseAuth.instance);
});

class CallController {
  final FirebaseAuth fireAuth;
  final CallRepository callRepository;
  final ProviderRef ref;

  CallController({
    required this.fireAuth,
    required this.callRepository,
    required this.ref,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(
      BuildContext context,
      String receiverUserId,
      String receiverUserName,
      String receiverUserProfilePic,
      bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();
      Call senderCallData = Call(
          callerId: fireAuth.currentUser!.uid,
          callerName: value!.name,
          callerPic: value.profileUrl,
          receiverId: receiverUserId,
          receiverName: receiverUserName,
          receieverPic: receiverUserProfilePic,
          callId: callId,
          hasDialled: true);

      Call receiverCallData = Call(
          callerId: fireAuth.currentUser!.uid,
          callerName: value.name,
          callerPic: value.profileUrl,
          receiverId: receiverUserId,
          receiverName: receiverUserName,
          receieverPic: receiverUserProfilePic,
          callId: callId,
          hasDialled: false);
      if (isGroupChat) {
        callRepository.makeGroupCall(context, senderCallData, receiverCallData);
      } else {
        callRepository.makeCall(context, senderCallData, receiverCallData);
      }
    });
  }

  void endCall(BuildContext context, String callerId, String receiverId) {
    callRepository.endCall(context, callerId, receiverId);
  }
}
