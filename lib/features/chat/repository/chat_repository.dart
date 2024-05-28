// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/chat_contacts.dart';
import 'package:whatsapp_clone/models/group.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, fireAuth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth fireAuth;

  ChatRepository({required this.firestore, required this.fireAuth});

  Stream<List<ChatContacts>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContacts> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContacts.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(
          ChatContacts(
            name: user.name,
            profilePicture: user.profileUrl,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        final group = Group.fromMap(document.data());

        if (group.membersId.contains(fireAuth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var document in event.docs) {
          messages.add(Message.fromMap(document.data()));
        }
        return messages;
      },
    );
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var document in event.docs) {
          messages.add(Message.fromMap(document.data()));
        }
        return messages;
      },
    );
  }

  void saveDataToContactsSubCollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timeSent,
    String receiverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(receiverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      var receiverChatContact = ChatContacts(
        name: senderUserData.name,
        profilePicture: senderUserData.profileUrl,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(fireAuth.currentUser!.uid)
          .set(receiverChatContact.toMap());

      var senderChatContact = ChatContacts(
        name: receiverUserData!.name,
        profilePicture: receiverUserData.profileUrl,
        contactId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .set(senderChatContact.toMap());
    }
  }

  // void saveMessageToMessageSubCollection({
  //   required String receiverUserId,
  //   required String text,
  //   required DateTime timeSent,
  //   required String messageId,
  //   required String senderUserName,
  //   required String? receiverUserName,
  //   required MessageEnum messageType,
  //   required MessageReply? messageReply,
  //   required bool isGroupChat,
  // }) async {
  //   final message = Message(
  //     senderId: fireAuth.currentUser!.uid,
  //     receiverId: receiverUserId,
  //     text: text,
  //     type: messageType,
  //     timeSent: timeSent,
  //     messageId: messageId,
  //     isSeen: false,
  //     repliedMessage: messageReply == null ? '' : messageReply.message,
  //     repliedTo: messageReply == null
  //         ? ''
  //         : messageReply.isMe
  //             ? senderUserName
  //             : receiverUserName ?? '',
  //     repliedMessageType:
  //         messageReply == null ? MessageEnum.text : messageReply.messageEnum,
  //   );

  //   if (isGroupChat) {
  //     log("This is GroupChat");
  //     await firestore
  //         .collection('groups')
  //         .doc(receiverUserId)
  //         .collection('chats')
  //         .doc(messageId)
  //         .set(message.toMap());
  //   } else {
  //     await firestore
  //         .collection('users')
  //         .doc(fireAuth.currentUser!.uid)
  //         .collection('chats')
  //         .doc(receiverUserId)
  //         .collection('messages')
  //         .doc(messageId)
  //         .set(message.toMap());

  //     await firestore
  //         .collection('users')
  //         .doc(receiverUserId)
  //         .collection('chats')
  //         .doc(fireAuth.currentUser!.uid)
  //         .collection('messages')
  //         .doc(messageId)
  //         .set(message.toMap());
  //   }
  // }

  void saveMessageToMessageSubCollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? recieverUserName,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: fireAuth.currentUser!.uid,
      receiverId: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if (isGroupChat) {
      // groups -> group id -> chat -> message
      await firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      // users -> sender id -> reciever id -> messages -> message id -> store message
      await firestore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
      // users -> eciever id  -> sender id -> messages -> message id -> store message
      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(fireAuth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }
  // void sendTextMessage({
  //   required BuildContext context,
  //   required String text,
  //   required String receiverUserId,
  //   required UserModel senderUser,
  //   required MessageReply? messageReply,
  //   required bool isGroupChat,
  // }) async {
  //   try {
  //     var timeSent = DateTime.now();
  //     var messageId = const Uuid().v1();
  //     UserModel? receiverUserData;

  //     if (!isGroupChat) {
  //       var userDataMap =
  //           await firestore.collection('users').doc(receiverUserId).get();
  //       receiverUserData = UserModel.fromMap(userDataMap.data()!);
  //     }

  //     saveDataToContactsSubCollection(
  //       senderUser,
  //       receiverUserData,
  //       text,
  //       timeSent,
  //       receiverUserId,
  //       isGroupChat,
  //     );

  //     saveMessageToMessageSubCollection(
  //       receiverUserId: receiverUserId,
  //       text: text,
  //       timeSent: timeSent,
  //       messageId: messageId,
  //       senderUserName: senderUser.name,
  //       receiverUserName: receiverUserData!.name,
  //       messageType: MessageEnum.text,
  //       messageReply: messageReply,
  //       isGroupChat: isGroupChat,
  //     );
  //   } catch (e) {
  //     showSnackBar(context, '$e');
  //   }
  // }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      saveMessageToMessageSubCollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUser,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      String fileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebaseStorage(
              'chat/${messageEnum.type}/${senderUser.uid}/$receiverUserId/$messageId',
              file);

      UserModel receiverUserData;
      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMessage;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMessage = '📸 photo';
          break;
        case MessageEnum.audio:
          contactMessage = '🎵 audio';
          break;
        case MessageEnum.gif:
          contactMessage = 'GIF';
          break;
        case MessageEnum.video:
          contactMessage = '🎬 video';
          break;
        default:
          contactMessage = 'GIF';
          break;
      }

      saveDataToContactsSubCollection(
        senderUser,
        receiverUserData,
        contactMessage,
        timeSent,
        receiverUserId,
        isGroupChat,
      );
      saveMessageToMessageSubCollection(
        recieverUserId: receiverUserId,
        text: fileUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        senderUsername: senderUser.name,
        recieverUserName: receiverUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  void sendGifMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);
      saveDataToContactsSubCollection(
        senderUser,
        receiverUserData,
        'GIF',
        timeSent,
        receiverUserId,
        isGroupChat,
      );
      saveMessageToMessageSubCollection(
        recieverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        senderUsername: senderUser.name,
        username: senderUser.name,
        recieverUserName: receiverUserData.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserId, String messageId) async {
    try {
      await firestore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(fireAuth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}
