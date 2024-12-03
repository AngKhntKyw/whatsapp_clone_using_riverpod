import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getCurrentUserData();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({required this.authRepository, required this.ref});

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void verifyOTP(
      BuildContext context, String verificationId, String otp) async {
    authRepository.verifyOTP(
        context: context, verificationId: verificationId, otp: otp);
  }

  void signUp(BuildContext context, String email, String password) async {
    authRepository.signUp(context: context, email: email, password: password);
  }

  void signIn(BuildContext context, String email, String password) async {
    authRepository.signIn(context: context, email: email, password: password);
  }

  void saveUserDataToFirebase(
      String name, File? imageFile, BuildContext context) async {
    authRepository.saveUserDataToFirebase(
        name: name, imageFile: imageFile, ref: ref, context: context);
  }

  Future<UserModel?> getCurrentUserData() async {
    return await authRepository.getCurrentUserData();
  }

  Stream<UserModel> userDateById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }
}
