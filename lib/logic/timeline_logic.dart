import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/logic/data/timeline_data.dart';

class TimelineLogic {
  List<TimelineEvent> events = [];

  void init() {
    // Create an event for each wonder, and merge it with the list of GlobalEvents
/*
    events = [
      ...GlobalEventsData().globalEvents,
      ...wondersLogic.all.map(
        (w) => TimelineEvent(
          w.startYr,
          StringUtils.supplant($strings.timelineLabelConstruction.toString(), {'{title}': w.title}),
        ),
      )
    ];
 */

    events = [
      ...GlobalEventsData().globalEvents,
      ...resumeLogic.all.map(
            (w) => TimelineEvent(
              w.startYr,
              $strings.timelineLabelConstruction(w.title),
            ),
      )
    ];
  }
}
