import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_type.dart';
import 'package:wonders/logic/data/resume_data.dart';

class CmnExpData extends ResumeData {
  CmnExpData(jsonData)
      : super(
          type: ResumeType.cmn,
          title: jsonData['cmn']['title'],
          startYr: jsonData['cmn']['startYr'],
          endYr: jsonData['cmn']['endYr']
        );
}
