part of '../wonders_chat2_screen.dart';

class _EventsList extends StatefulWidget {
  const _EventsList({Key? key, required this.data}) : super(key: key);
  //const _EventsList({Key? key}) : super(key: key);
  final Map data;

  @override
  State<_EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<_EventsList> {
  final ScrollController _scroller = ScrollController();

  void scrollToBottom() {
    _scroller.animateTo(
      _scroller.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopRouterOnOverScroll(
      controller: _scroller,
      child: LayoutBuilder(builder: (_, constraints) {
        return AnimatedBuilder(
              animation: _scroller,
              builder: (_, __) {
                bool showBackdrop = true;
                double backdropAmt = 0;
                if (_scroller.hasClients) {
                  double blurStart = 50;
                  double maxScroll = 150;
                  double scrollPx = _scroller.position.pixels - blurStart;
                  // Normalize scroll position to a value between 0 and 1
                  backdropAmt = (_scroller.position.pixels - blurStart).clamp(0, maxScroll) / maxScroll;
                  // Disable backdrop once it is offscreen for an easy perf win
                  showBackdrop = (scrollPx <= 500);
                }
                // Container provides a underlay which gets darker as the background blurs
                return Stack(
                  children: [
                    if (showBackdrop) ...[
                      AppBackdrop(
                          strength: backdropAmt,
                          child: IgnorePointer(
                            child: Container(
                              color: $styles.colors.greyStrong.withOpacity(backdropAmt * .6),
                            ),
                          )),
                    ],
                    _buildScrollingList()
                  ],
                );
              },
            );

      }),
    );
  }

  Widget _buildScrollingList() {
    Container buildHandle() {
      return Container(
        width: 35,
        height: 5,
        decoration: BoxDecoration(color: $styles.colors.greyMedium, borderRadius: BorderRadius.circular(99)),
      );
    }

    final listItems = <Widget>[];
    for (var e in widget.data.entries) {
      final delay = 100.ms + (100 * listItems.length).ms;

      e.key%2==0 ?
      listItems.add(
        TimelineEventCard(year: e.key, text: e.value)
            .animate()
            //.fade(delay: delay, duration: $styles.times.med * 1.5)
            .slide(begin: Offset(0, 1), curve: Curves.easeOutBack)
      ) :
      listItems.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Q：' + e.value, style: $styles.text.bodyBold)
          )
      );
    }

    return SingleChildScrollView(
      controller: _scroller,
      child: Column(
        children: [
          IgnorePointer(child: Gap(0)),
          Container(
            decoration: BoxDecoration(
              color: $styles.colors.white,
              borderRadius: BorderRadius.circular($styles.corners.md),
            ),
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
            child: Column(
              children: [
                Gap($styles.insets.xs),
                buildHandle(),
                Gap($styles.insets.sm),
                ...listItems,
                Gap($styles.insets.sm),
                CompassDivider(isExpanded: true),
                Gap(20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
