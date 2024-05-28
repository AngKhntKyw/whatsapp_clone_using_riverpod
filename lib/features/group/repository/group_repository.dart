// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/group.dart';

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(
      fireStore: FirebaseFirestore.instance,
      fireAuth: FirebaseAuth.instance,
      ref: ref),
);

class GroupRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth fireAuth;
  final ProviderRef ref;
  GroupRepository({
    required this.fireStore,
    required this.fireAuth,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePicture,
      List<Contact> selectedContactList) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContactList.length; i++) {
        final userCollection = await fireStore
            .collection('users')
            .where('phoneNumber',
                isEqualTo:
                    selectedContactList[i].phones[0].number.replaceAll(' ', ''))
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
        }
      }
      final groupId = const Uuid().v1();
      String groupProfile = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebaseStorage('group/$groupId', profilePicture);

      final group = Group(
        groupName: name,
        groupId: groupId,
        groupPicture: groupProfile,
        lastMessage: '',
        messageSenderId: fireAuth.currentUser!.uid,
        membersId: [fireAuth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
      );
      await fireStore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context, "$e");
    }
  }
}
