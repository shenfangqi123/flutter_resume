import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/controls/app_loading_indicator.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:wonders/logic/common/video_controller.dart';

class FullscreenVideoPage extends StatefulWidget {
  FullscreenVideoPage({Key? key, required this.videoUrl, required this.aspectRatio}) : super(key: key);
  final String videoUrl;
  final double aspectRatio;

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    appLogic.setDeviceOrientation(null);
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final c = await createController(widget.videoUrl);
      c.setLooping(true);
      c.setVolume(0);
      c.play();
      if (!mounted) return;
      setState(() => _controller = c);
    } catch (_) {}
  }

  void destoryVideoPlay() {
    final tmp = _controller;
    if (tmp != null) {
      tmp.pause();
      tmp.dispose();
    }
  }

  @override
  void dispose() {
    destoryVideoPlay();
    appLogic.setDeviceOrientation(Axis.vertical);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double aspect = context.isLandscape ? MediaQuery.of(context).size.aspectRatio : 9 / 9;
    aspect = widget.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: aspect,
              child: Stack(
                children: [
                  const Center(child: AppLoadingIndicator()),
                  if (_controller != null) VideoPlayer(_controller!),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all($styles.insets.md),
              child: const BackBtn(),
            ),
          ),
        ],
      ),
    );
  }
}
