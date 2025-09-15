import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_data.dart';
import 'package:wonders/logic/data/resume_type.dart';

class KaiseiExpData extends ResumeData {
  KaiseiExpData(jsonData)
      : super(
          type: ResumeType.kaisei,
          title: jsonData['kaisei']['title'],
          startYr: jsonData['kaisei']['startYr'],
          endYr: jsonData['kaisei']['endYr']
        );
}
