import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:wonders/logic/data/resume_type.dart';

class ResumeData extends Equatable {
   ResumeType type;
   String title;
   int startYr;
   int endYr;

   // Add a default constructor
   ResumeData({
     required this.type,
     required this.title,
     this.startYr = 0,
     this.endYr = 0
   });

  String get titleWithBreaks => title.replaceFirst(' ', '\n');

  @override
  List<Object?> get props => [type, title];

}
