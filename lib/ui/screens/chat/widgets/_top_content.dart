part of '../wonders_chat_screen.dart';

class _TopContent extends StatelessWidget {
  const _TopContent({Key? key}) : super(key: key);

  Color _fixLuminence(Color color, [double luminence = 0.35]) {
    double d = luminence - color.computeLuminance();
    if (d <= 0) return color;
    int r = color.red, g = color.green, b = color.blue;
    return Color.fromARGB(255, (r + (255 - r) * d).toInt(), (g + (255 - g) * d).toInt(), (b + (255 - b) * d).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: MergeSemantics(
        child: LightText(
          child: SeparatedColumn(
            separatorBuilder: () => Gap($styles.insets.xs * 1.5),
            //padding: EdgeInsets.only(top: $styles.insets.md, bottom: $styles.insets.sm),
            padding: EdgeInsets.only(top: 0, bottom: $styles.insets.sm*6),
            children: [
              /// Text and image in a stack
              Expanded(
                child: Stack(children: [
                  /// Image with fade on btm
                  Center(
                    child: _buildImageWithFade(context),
                  ),

                  /// Title text
                  BottomCenter(
                    child: WonderTitleText("HARUKA", enableHero: false),
                  )
                ]),
              ),

              //_buildEraTextRow(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithFade(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(
        children: [
          /// Image
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Image.asset(
              //'assets/images/_common/temple.png',
              'assets/images/chichen_itza/flattened.jpg',
              width: 200,
              fit: BoxFit.cover,
              alignment: Alignment(0, -.5),
            ),
          ),

          /// Vertical gradient on btm
          Positioned.fill(
            child: BottomCenter(
              child: ListOverscollGradient(bottomUp: true, size: 200),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEraTextRow(BuildContext context) {
    final textStyle = $styles.text.body.copyWith(color: $styles.colors.accent2, height: 1);
    return SeparatedRow(
      separatorBuilder: () => Gap($styles.insets.sm),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDot(context),
      ],
    ).animate().fade(delay: $styles.times.pageTransition);
  }

  Widget _buildDot(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: $styles.colors.accent2, borderRadius: BorderRadius.circular(99)),
    );
  }
}
