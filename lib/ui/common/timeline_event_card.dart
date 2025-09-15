import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';

class TimelineEventCard extends StatelessWidget {
  const TimelineEventCard({Key? key, required this.year, required this.text}) : super(key: key);
  final int year;
  final String text;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.only(bottom: $styles.insets.sm),
        child: Container(
          color: $styles.colors.offWhite,
          padding: EdgeInsets.all($styles.insets.sm),
          child: Row(
            children: [
              SizedBox(
                width: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      //width: 256,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5.0,
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage('assets/images/ailawyer/lawyer1.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    //Text('${year.abs()}', style: $styles.text.h3.copyWith(fontWeight: FontWeight.w400, height: 1)),
                    //Text(StringUtils.getYrSuffix(year), style: $styles.text.bodySmall),
                  ],
                ),
              ),
              Center(child: Container(width: 1, height: 50, color: $styles.colors.black)),
              Gap($styles.insets.sm),
              Expanded(
                child: Text(text, style: $styles.text.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
