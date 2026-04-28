import 'package:wonders/logic/config.dart';

class PresentationData {
  static const String baseImagePath = UploadConfig.remoteBaseUrl;

  PresentationData(
      {required this.objectId,
      required this.year,
      required this.title,
      required this.keywords,
      required this.content,
      required this.type,
      required this.imagePath,
      required this.aspectRatio,
      required this.date,
      required this.country,
      required this.isPublic});
  final String
      objectId; // Artifact ID, used to identify through MET server calls.
  final int year;
  final String title; // Artifact title / name
  final String keywords;
  final String content;
  final String type;
  final String imagePath; // Artifact primary image URL (can have multiple)
  final double aspectRatio;
  final String date; // Date of creation
  final String country; // Country of origin
  final bool isPublic;

  String get imageUrl => '$baseImagePath$imagePath.png';
  String get videoUrl => '$baseImagePath$imagePath.mp4';

  PresentationData copyWith({
    int? year,
    String? title,
    String? keywords,
    String? content,
    String? type,
    String? imagePath,
    double? aspectRatio,
    String? date,
    String? country,
    bool? isPublic,
  }) {
    return PresentationData(
      objectId: objectId,
      year: year ?? this.year,
      title: title ?? this.title,
      keywords: keywords ?? this.keywords,
      content: content ?? this.content,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      date: date ?? this.date,
      country: country ?? this.country,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
