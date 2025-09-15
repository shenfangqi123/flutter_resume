import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/http_client.dart';
import 'package:wonders/logic/data/artifact_data.dart';
import 'package:wonders/logic/data/prentation_data.dart';
import 'dart:convert';

class MetAPIService {
  final String _baseMETUrl = 'https://collectionapi.metmuseum.org/public/collection/v1';

  Future<ServiceResult<ArtifactData?>> getObjectByID(String id) async {
    HttpResponse? response = await HttpClient.send('$_baseMETUrl/objects/$id');
    return ServiceResult<ArtifactData?>(response, _parseArtifactData);
  }

  Future<PresentationData?> getPresentationByID(String id)  async {
    final jsonString = await rootBundle.loadString('assets/data/resume_presentation.json');
    final jsonData = jsonDecode(jsonString);
    List<dynamic> items = jsonData['items'];



    // Find the record with the given ID
    Map<String, dynamic>? record;
    for (var item in items) {
      if (item['id'].toString() == id) {
        record = item;
        break;
      }
    }

    if(record != null) {
      return _parsePresentationData(record);
    } else {
      return null;
    }
  }

  ArtifactData? _parseArtifactData(Map<String, dynamic> content) {
    // Source: https://metmuseum.github.io/
    return ArtifactData(
      objectId: content['objectID'].toString(),
      title: content['title'] ?? '',
      image: content['primaryImage'] ?? '',
      date: content['objectDate'] ?? '',
      objectType: content['objectName'] ?? '',
      period: content['period'] ?? '',
      country: content['country'] ?? '',
      medium: content['medium'] ?? '',
      dimension: content['dimension'] ?? '',
      classification: content['classification'] ?? '',
      culture: content['culture'] ?? '',
      objectBeginYear: content['objectBeginDate'],
      objectEndYear: content['objectEndDate'],
    );
  }

  PresentationData? _parsePresentationData(Map<String, dynamic> content) {
    return PresentationData(
      objectId: content['id'].toString(),
      title: content['title'] ?? '',
      keywords: content['keywords'] ?? '',
      content: content['content'] ?? '',
      aspectRatio: content['aspectRatio'] ?? '',
      type: content['type'] ?? '',
      imagePath: content['imagePath'] ?? '',
      date: content['date'] ?? '',
      country: content['country'] ?? '',
    );
  }

}
