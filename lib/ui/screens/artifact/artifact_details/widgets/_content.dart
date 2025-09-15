part of '../artifact_details_screen.dart';

class _Content extends StatelessWidget {
  const _Content({Key? key, required this.data}) : super(key: key);
  final PresentationData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
      child: Column(
        children: [
          Gap($styles.insets.xl),
          Semantics(
            header: true,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: $styles.text.h2.copyWith(color: $styles.colors.offWhite, height: 1.2),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ).animate().fade(delay: 250.ms, duration: 600.ms),
          ),
          Gap($styles.insets.lg),
          Animate().toggle(
              delay: 500.ms,
              builder: (_, value, __) {
                return CompassDivider(isExpanded: !value, duration: $styles.times.med);
              }),
          Gap($styles.insets.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...[
                _InfoRow($strings.artifactDetailsLabelDate, data.date),
                //_InfoRow($strings.artifactDetailsLabelGeography, data.country),
                _InfoRow('技術分野', data.keywords),
                _InfoFullRow(data.content),
              ]
                  .animate(interval: 100.ms)
                  .fade(delay: 600.ms, duration: $styles.times.med)
                  .slide(begin: Offset(0.2, 0), curve: Curves.easeOut),
            ],
          ),
          Gap($styles.insets.md),
          Text(
            $strings.homeMenuAboutMet,
            style: $styles.text.caption.copyWith(color: $styles.colors.accent2),
          ),
          Gap($styles.insets.offset),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {Key? key}) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: value.isEmpty,
      child: MergeSemantics(
        child: Padding(
          padding: EdgeInsets.only(bottom: $styles.insets.sm),
          child: Row(children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: $styles.text.titleFont.copyWith(color: $styles.colors.accent2),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '--' : value,
                style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


class _InfoFullRow extends StatelessWidget {
  const _InfoFullRow(this.value, {Key? key}) : super(key: key);
  final String value;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: value.isEmpty,
      child: MergeSemantics(
        child: Padding(
          padding: EdgeInsets.only(bottom: $styles.insets.sm),
          child: Row(children: [
            Expanded(
              child: Text(
                value.isEmpty ? '--' : value,
                style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
