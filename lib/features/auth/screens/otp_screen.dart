import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';

class OTPScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;
  const OTPScreen({super.key, required this.verificationId});

  void verifyOTP(WidgetRef ref, BuildContext context, String otp) {
    if (otp.isNotEmpty) {
      ref.read(authControllerProvider).verifyOTP(context, verificationId, otp);
    } else {
      showSnackBar(context, "Please Enter the OTP.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final otpController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your phone number'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text("We have sent an SMS message with a code."),
          const SizedBox(height: 20),
          SizedBox(
            width: size.width * 0.5,
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '- - - - - -',
                hintStyle: TextStyle(
                  fontSize: 30,
                ),
              ),
              onChanged: (value) {
                if (value.length == 6) {
                  verifyOTP(ref, context, value.trim());
                }
              },
            ),
          ),
          Container()
        ],
      ),
    );
  }
}
