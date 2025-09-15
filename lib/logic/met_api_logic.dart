import 'dart:collection';

import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/logic/data/artifact_data.dart';
import 'package:wonders/logic/data/prentation_data.dart';
import 'package:wonders/logic/met_api_service.dart';

import 'package:wonders/logic/common/http_client.dart';

class MetAPILogic {
  final HashMap<String, ArtifactData?> _artifactCache = HashMap();
  final HashMap<String, PresentationData?> _prentationCache = HashMap();

  MetAPIService get service => GetIt.I.get<MetAPIService>();

  /// Returns artifact data by ID. Returns null if artifact cannot be found. */
  Future<ArtifactData?> getArtifactByID(String id) async {
    if (_artifactCache.containsKey(id)) return _artifactCache[id];
    ServiceResult<ArtifactData?> result = (await service.getObjectByID(id));
    if (!result.success) throw StringUtils.supplant($strings.artifactDetailsErrorNotFound.toString(), {'{artifactId}': id});
    ArtifactData? artifact = result.content;
    return _artifactCache[id] = artifact;
  }

  Future<PresentationData?> getPresentationByID(String id) async {
    if (_artifactCache.containsKey(id)) return _prentationCache[id];
    PresentationData? result = (await service.getPresentationByID(id));
    //if (!result.success) throw StringUtils.supplant($strings.artifactDetailsErrorNotFound.toString(), {'{artifactId}': id});
    PresentationData? presentation = result;
    return _prentationCache[id] = presentation;
  }

}
