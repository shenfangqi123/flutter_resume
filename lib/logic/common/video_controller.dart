import 'package:video_player/video_player.dart';

import 'package:wonders/logic/common/video_controller_factory_io.dart'
    if (dart.library.html) 'package:wonders/logic/common/video_controller_factory_web.dart' as impl;

/// Creates an initialized [VideoPlayerController] with simple caching on mobile/desktop
/// and plain network loading on Web (to leverage browser cache).
Future<VideoPlayerController> createController(String url) => impl.createController(url);
