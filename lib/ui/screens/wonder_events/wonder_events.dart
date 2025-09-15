import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/app_backdrop.dart';
import 'package:wonders/ui/common/compass_divider.dart';
import 'package:wonders/ui/common/curved_clippers.dart';
import 'package:wonders/ui/common/hidden_collectible.dart';
import 'package:wonders/ui/common/list_gradient.dart';
import 'package:wonders/ui/common/pop_router_on_over_scroll.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/common/timeline_event_card.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';

part 'widgets/_events_list.dart';
part 'widgets/_top_content.dart';

class WonderEvents extends StatelessWidget {
  static const double _topHeight = 450;
  WonderEvents({Key? key, required this.type}) : super(key: key);
  final WonderType type;
  late final Future<Map<int, String>> _dataResume = resumeLogic.getResumeEventData();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        color: $styles.colors.black,
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<Map<int, String>>(
            future: _dataResume,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final dataResume = snapshot.data!;
                return Stack(
                  children: [
                    _TopContent(),
                    _EventsList(data: dataResume, type: type),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      );
    });
  }



}
