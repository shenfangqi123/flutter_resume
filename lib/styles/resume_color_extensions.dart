import 'package:wonders/common_libs.dart';

extension ResumeColorExtensions on ResumeType {
  Color get bgColor {
    switch (this) {
      case ResumeType.changjiang:
        return const Color(0xFF16184D);
      case ResumeType.raytec:
        return const Color(0xFF642828);
      case ResumeType.anshex:
        return const Color(0xFF444B9B);
      case ResumeType.weic1:
        return const Color(0xFF1E736D);
      case ResumeType.weic2:
        return const Color(0xFF164F2A);
      case ResumeType.cmn:
        return const Color(0xFF0E4064);
      case ResumeType.self:
        return const Color(0xFFC96454);
      case ResumeType.kaisei:
        return const Color(0xFF1C4D46);
    }
  }

  Color get fgColor {
    switch (this) {
      case ResumeType.changjiang:
        return const Color(0xFF444B9B);
      case ResumeType.raytec:
        return const Color(0xFF688750);
      case ResumeType.anshex:
        return const Color(0xFF1B1A65);
      case ResumeType.weic1:
        return const Color(0xFF4AA39D);
      case ResumeType.weic2:
        return const Color(0xFFE2CFBB);
      case ResumeType.cmn:
        return const Color(0xFFC1D9D1);
      case ResumeType.self:
        return const Color(0xFF642828);
      case ResumeType.kaisei:
        return const Color(0xFFED7967);
    }
  }
}
