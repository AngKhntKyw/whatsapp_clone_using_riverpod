// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      image = File(xFile.path);
    }
  } catch (e) {
    showSnackBar(context, '$e');
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    XFile? xFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (xFile != null) {
      video = File(xFile.path);
    }
  } catch (e) {
    showSnackBar(context, '$e');
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? giphyGif;
  try {
    giphyGif = await Giphy.getGif(
        context: context, apiKey: 'JEw73mLNZs8DqRK4N7L6AyXwrIHOB4Ix');
  } catch (e) {
    showSnackBar(context, '$e');
  }
  return giphyGif;
}
