import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_data.dart';
import 'package:wonders/logic/data/resume_type.dart';

class Weic1ExpData extends ResumeData {
  Weic1ExpData(jsonData)
      : super(
          type: ResumeType.weic1,
          title: jsonData['weic1']['title'],
          startYr: jsonData['weic1']['startYr'],
          endYr: jsonData['weic1']['endYr']
        );
}
