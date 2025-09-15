import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_data.dart';
import 'package:wonders/logic/data/resume_type.dart';

class RaytecExpData extends ResumeData {
  RaytecExpData(jsonData)
      : super(
          type: ResumeType.raytec,
          title: jsonData['raytec']['title'],
          startYr: jsonData['raytec']['startYr'],
          endYr: jsonData['raytec']['endYr']
        );
}
