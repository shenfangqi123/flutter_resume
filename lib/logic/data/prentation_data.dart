class PresentationData {
  static const String baseImagePath = 'https://resume-flutter.s3.ap-northeast-1.amazonaws.com/';

  PresentationData({
    required this.objectId,
    required this.title,
    required this.keywords,
    required this.content,
    required this.type,
    required this.imagePath,
    required this.aspectRatio,
    required this.date,
    required this.country
  });
  final String objectId; // Artifact ID, used to identify through MET server calls.
  final String title; // Artifact title / name
  final String keywords;
  final String content;
  final String type;
  final String imagePath; // Artifact primary image URL (can have multiple)
  final double aspectRatio;
  final String date; // Date of creation
  final String country; // Country of origin

  String get imageUrl => baseImagePath + imagePath +".png";
  String get videoUrl => baseImagePath + imagePath +".mp4";

}
