// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/mobile_layout_screen.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  AuthRepository({required this.firebaseAuth, required this.firestore});

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) async {
          await firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          showSnackBar(context, error.message!);
          log("${error.message}");
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) => Navigator.pushNamed(
            context, OTPScreen.routeName,
            arguments: verificationId),
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String otp}) async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      await firebaseAuth.signInWithCredential(phoneAuthCredential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? imageFile,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      final uid = firebaseAuth.currentUser!.uid;
      String imageUrl =
          'https://i.pinimg.com/564x/ac/45/51/ac4551cc2fd9359885298075a2b5e9d7.jpg';
      if (imageFile != null) {
        imageUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebaseStorage('profilePic/$uid', imageFile);
      }
      var user = UserModel(
        uid: uid,
        name: name,
        profileUrl: imageUrl,
        isOnline: true,
        phoneNumber: firebaseAuth.currentUser!.phoneNumber!,
        groupId: [],
      );
      await firestore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileLayoutScreen(),
          ),
          (route) => false);
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    var userData = await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser?.uid)
        .get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  Stream<UserModel> userData(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  void setUserState(bool isOnline) async {
    await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({
      'isOnline': isOnline,
    });
  }
}
