import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createController(String url) async {
  final controller = VideoPlayerController.networkUrl(Uri.parse(url));
  await controller.initialize();
  return controller;
}

