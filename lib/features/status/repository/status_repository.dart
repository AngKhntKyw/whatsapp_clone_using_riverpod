// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/status_model.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final statusRepositoryProvider = Provider((ref) => StatusRepository(
      fireStore: FirebaseFirestore.instance,
      fireAuth: FirebaseAuth.instance,
      ref: ref,
    ));

class StatusRepository {
  final FirebaseFirestore fireStore;
  final FirebaseAuth fireAuth;
  final ProviderRef ref;
  StatusRepository({
    required this.fireStore,
    required this.fireAuth,
    required this.ref,
  });

  void uploadStatus({
    required String userName,
    required String profilePicture,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String uid = fireAuth.currentUser!.uid;
      String imageurl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebaseStorage(
            '/status/$statusId$uid',
            statusImage,
          );
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        for (Contact contact in contacts) {
          contact.phones.add(Phone("+959000000000"));
        }
      }
      log("ContactList : ${contacts.length}");

      List<String> uidWhoCanSee = [];

      for (Contact contact in contacts) {
        var userDataFirebase = await fireStore
            .collection('users')
            .where(
              'phoneNumber',
              isEqualTo: contact.phones[0].number.replaceAll(
                ' ',
                '',
              ),
            )
            .get();

        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoCanSee.add(userData.uid);
        }
      }

      log("WhOCanSee : ${uidWhoCanSee.length}");

      List<String> statusImageUrls = [];
      var statusesSnapshot = await fireStore
          .collection('status')
          .where(
            'uid',
            isEqualTo: fireAuth.currentUser!.uid,
          )
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageurl);
        await fireStore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [imageurl];
      }

      Status status = Status(
        uid: uid,
        userName: userName,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePicture: profilePicture,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );
      log("status : $status");

      await fireStore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        for (Contact contact in contacts) {
          contact.phones.add(Phone("+959000000000"));
        }
      }

      log("ContactList : ${contacts.length}");

      for (Contact contact in contacts) {
        var statusSnapShot = await fireStore
            .collection('status')
            .where(
              'phoneNumber',
              isEqualTo: contact.phones[0].number.replaceAll(
                ' ',
                '',
              ),
            )
            // .where('createAt',
            //     isGreaterThan: DateTime.now()
            //         .subtract(const Duration(hours: 24))
            //         .microsecondsSinceEpoch)
            .get();
        for (var tempData in statusSnapShot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(fireAuth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      showSnackBar(context, '$e');
    }
    return statusData;
  }
}
