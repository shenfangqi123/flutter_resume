class SearchData {
  static const String baseImagePath = 'https://resume-flutter.s3.ap-northeast-1.amazonaws.com/';

  const SearchData(this.year, this.id, this.type, this.title, this.keywords, this.imagePath, [this.aspectRatio = 0]);
  final int year;
  final int id;
  final String type;
  final String imagePath;
  final String keywords;
  final String title;
  final double aspectRatio;

  String get imageUrl => baseImagePath + imagePath +".png";
  String get videoUrl => baseImagePath + imagePath +".mp4";

  // used by the search helper tool:
  String write() =>
      "SearchData($year, $id, '$title', '$keywords', '$imagePath'${aspectRatio == 0 ? '' : ', ${aspectRatio.toStringAsFixed(2)}'})";
}
