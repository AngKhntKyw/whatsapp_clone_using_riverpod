import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/features/auth/screens/login_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case OTPScreen.routeName:
      final verificationId = routeSettings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(verificationId: verificationId),
      );
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const UserInformationScreen());
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const SelectContactsScreen());
    case MobileChatScreen.routeName:
      final arguments = routeSettings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(name: name, uid: uid));
    case ConfirmStatusScreen.routeName:
      final file = routeSettings.arguments as File;
      return MaterialPageRoute(
          builder: (context) => ConfirmStatusScreen(file: file));
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
              body: ErrorScreen(error: 'This page does note exit!')));
  }
}
