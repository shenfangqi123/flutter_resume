import 'dart:io' show File;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createController(String url) async {
  final File file = await DefaultCacheManager().getSingleFile(url);
  final controller = VideoPlayerController.file(file);
  await controller.initialize();
  return controller;
}

