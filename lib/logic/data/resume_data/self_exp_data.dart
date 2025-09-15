import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_data.dart';
import 'package:wonders/logic/data/resume_type.dart';

class SelfExpData extends ResumeData {
  SelfExpData(jsonData)
      : super(
          type: ResumeType.self,
          title: jsonData['self']['title'],
          startYr: jsonData['self']['startYr'],
          endYr: jsonData['self']['endYr']
        );
}
