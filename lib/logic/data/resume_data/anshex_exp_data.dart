import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_type.dart';
import 'package:wonders/logic/data/resume_data.dart';

class AnshexExpData extends ResumeData {
  AnshexExpData(jsonData)
      : super(
          type: ResumeType.anshex,
          title: jsonData['anshex']['title'],
          startYr: jsonData['anshex']['startYr'],
          endYr: jsonData['anshex']['endYr']
        );
}
