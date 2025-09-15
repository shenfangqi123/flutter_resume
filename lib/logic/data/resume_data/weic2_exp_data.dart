import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_data.dart';
import 'package:wonders/logic/data/resume_type.dart';

class Weic2ExpData extends ResumeData {
  Weic2ExpData(jsonData)
      : super(
          type: ResumeType.weic2,
          title: jsonData['weic2']['title'],
          startYr: jsonData['weic2']['startYr'],
          endYr: jsonData['weic2']['endYr']
        );
}
