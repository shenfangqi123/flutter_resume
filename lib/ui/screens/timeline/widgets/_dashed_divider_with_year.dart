part of '../timeline_screen.dart';

class _DashedDividerWithYear extends StatelessWidget {
  const _DashedDividerWithYear(this.year, this.maxWidth, {Key? key}) : super(key: key);
  final int year;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    int yrGap = 1;
    final roundedYr = (year / yrGap).round() * yrGap;

    return Stack(
      children: [
        Center(child: DashedLine()),
        //left to make the position by job arr.

        Positioned.fill(
        left: 100,
        right: $styles.insets.sm,
        child: SeparatedRow(
            children: [
              Expanded(child: Container(alignment: Alignment.topCenter, height: 20, child: Image.asset('assets/images/_common/icons/cf.png', width: 20, height: 20, fit: BoxFit.cover))),
              Expanded(child: Container(alignment: Alignment.topCenter, height: 20, child: Image.asset('assets/images/_common/icons/jf.png', width: 20, height: 20, fit: BoxFit.cover))),
              Expanded(child: Container(height: 20)),
            ], separatorBuilder: () => Text(''))
        ),

        CenterRight(
          child: FractionalTranslation(
            translation: Offset(0, -.5),
            child: MergeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${roundedYr.abs()}',
                    style: $styles.text.h2.copyWith(color: $styles.colors.white, shadows: $styles.shadows.text),
                  ),
                  Gap($styles.insets.xs),
                  Text(
                    '年',
                    //StringUtils.getYrSuffix(roundedYr),
                    style: $styles.text.body.copyWith(
                      color: Colors.white,
                      shadows: $styles.shadows.textStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
