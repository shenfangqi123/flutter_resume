part of '../media_search_screen.dart';

class _ResultTile extends StatefulWidget {
  _ResultTile({Key? key, required this.onPressed, required this.data})
      : super(key: key);

  final void Function(SearchData data) onPressed;
  final SearchData data;

  @override
  _ResultTileState createState() => _ResultTileState();
}

class _ResultTileState extends State<_ResultTile> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.data.type == "video" && widget.data.id < 10000) {
      initVideoPlay(widget.data.videoUrl);
    }
  }

  Future initVideoPlay(String videoUrl) async {
    try {
      final controller = await createController(videoUrl);
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (e) {
      // ignore error and fallback to image
      destroyVideoPlay();
    }
  }

  void destroyVideoPlay() {
    final tmp = _controller;
    if (tmp != null) {
      tmp.pause();
      tmp.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    destroyVideoPlay();
  }

  @override
  Widget build(BuildContext context) {
    final content;
    if (_controller != null) {
      content = VideoPlayer(_controller!);
    } else {
      content = CachedNetworkImage(
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        imageUrl: widget.data.imageUrl,
      );
    }

    final child = AspectRatio(
      aspectRatio: (widget.data.aspectRatio == 0) ? (widget.data.id % 10) / 15 + 0.6 : max(0.5, widget.data.aspectRatio),
      child: ClipRRect(
          borderRadius: BorderRadius.circular($styles.insets.xs),
          child: Stack(
            children: <Widget>[
              Hero(
                  tag: "hero_"+widget.data.id.toString(),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    imageUrl: widget.data.imageUrl,
                  )
              ),
              content,
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onPressed(widget.data),
                  ),
                ),
              ),
            ],
          )
      ),
    );

    //return child;


    return VisibilityDetector(
      key: Key(widget.data.id.toString()),
      child: child,
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          // Release the video when it becomes invisible
          //destroyVideoPlay();
        }
      },
    );

  }
}
