import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:wonders/logic/common/json_prefs_file.dart';
import 'package:wonders/logic/config.dart';
import 'package:wonders/main.dart';
import 'package:wonders/logic/upload/upload_service.dart';

class PresentationRepo {
  static const String _cacheKey = 'resume_presentation_cache_v1';
  final JsonPrefsFile _cacheFile = JsonPrefsFile(_cacheKey);
  Future<Map<String, dynamic>> fetchRemote() async {
    final response = await http.get(
      Uri.parse(UploadConfig.remoteUrlFor(UploadConfig.presentationKey)),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode} while loading ${UploadConfig.presentationKey}',
      );
    }
    final bytes = response.bodyBytes;
    final data = _decode(bytes);
    await _cacheFile.save(data);
    return data;
  }

  Future<void> appendEntry(UploadResult result) async {
    Map<String, dynamic> data;
    try {
      data = await fetchRemote();
    } catch (_) {
      data = await _loadBundled();
    }
    final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[];
    items.add(result.toJson());
    data['items'] = items;

    final suggestions =
        (data['suggestions'] as List?)?.cast<String>() ?? <String>[];
    final newTags =
        result.keywords.split('|').where((tag) => tag.isNotEmpty).toSet();
    final merged = {...suggestions, ...newTags};
    data['suggestions'] = merged.toList();

    await _persist(data);
  }

  Future<void> saveAll(Map<String, dynamic> data) async {
    await _persist(data);
  }

  Future<void> deleteEntry({
    required String id,
    required String imagePath,
    required bool isVideo,
  }) async {
    final data = await fetchRemote();
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic>? removed;
    items.removeWhere((item) {
      final match = item['id'].toString() == id;
      if (match) removed = item;
      return match;
    });
    if (removed == null) {
      throw Exception('未找到对应的作品 (id=$id)');
    }

    final basePath = imagePath;
    final pngPath = '$basePath.png';
    final mp4Path = '$basePath.mp4';
    try {
      await Amplify.Storage.remove(
        path: amplify_core.StoragePath.fromString(pngPath),
      ).result;
    } catch (e) {
      debugPrint('删除图片 $pngPath 失败: $e');
    }

    if (isVideo) {
      try {
        await Amplify.Storage.remove(
          path: amplify_core.StoragePath.fromString(mp4Path),
        ).result;
      } catch (e) {
        debugPrint('删除视频 $mp4Path 失败: $e');
      }
    }

    data['items'] = items;
    await _persist(data);
  }

  Future<Map<String, dynamic>> loadRemotePreferred() async {
    try {
      return await fetchRemote();
    } catch (e, st) {
      debugPrint('Failed to load resume presentation data from S3: $e\n$st');
    }

    try {
      final cached = await _cacheFile.load();
      if (cached.isNotEmpty) {
        return _normalizeMap(cached);
      }
    } catch (e, st) {
      debugPrint('Failed to load cached resume presentation data: $e\n$st');
    }

    return _loadBundled();
  }

  Future<void> updateIsPublic(String id, bool isPublic) async {
    final data = await fetchRemote();
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    var updated = false;
    for (final item in items) {
      if (item['id'].toString() == id) {
        item['isPublic'] = isPublic;
        updated = true;
        break;
      }
    }
    if (!updated) {
      throw Exception('未找到对应的作品 (id=$id)');
    }
    await _persist(data);
  }

  Map<String, dynamic> _decode(List<int> bytes) {
    try {
      final jsonString = utf8.decode(bytes);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return _normalizeMap(data);
    } catch (e) {
      throw Exception('远端 JSON 解析失败: $e');
    }
  }

  Future<Map<String, dynamic>> _loadBundled() async {
    final jsonString =
        await rootBundle.loadString('assets/data/resume_presentation.json');
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return _normalizeMap(data);
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> source) {
    final data = Map<String, dynamic>.from(source);
    final items = (data['items'] as List?) ?? const [];
    data['items'] = items.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      map['isPublic'] = _parseBool(map['isPublic']);
      map['aspectRatio'] = _parseDouble(map['aspectRatio']);
      map['year'] = _parseInt(map['year']);
      return map;
    }).toList();
    final suggestions = (data['suggestions'] as List?) ?? const [];
    data['suggestions'] = suggestions.map((e) => e.toString()).toList();
    return data;
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    final payload = jsonEncode(data);
    await Amplify.Storage.uploadData(
      path: amplify_core.StoragePath.fromString(UploadConfig.presentationKey),
      data: amplify_core.StorageDataPayload.bytes(
        utf8.encode(payload),
        contentType: 'application/json; charset=utf-8',
      ),
      options: const amplify_core.StorageUploadDataOptions(
        metadata: {},
        pluginOptions: S3UploadDataPluginOptions(),
      ),
    ).result;
    await _cacheFile.save(data);
    resumeLogic.notifyPresentationUpdated();
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
