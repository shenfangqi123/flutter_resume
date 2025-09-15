import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_type.dart';
import 'package:wonders/logic/data/resume_data.dart';

class ChangjiangExpData extends ResumeData {
  ChangjiangExpData(jsonData)
      : super(
          type: ResumeType.changjiang,
          title: jsonData['changjiang']['title'],
          startYr: jsonData['changjiang']['startYr'],
          endYr: jsonData['changjiang']['endYr']
        );
}