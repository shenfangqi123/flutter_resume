import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:http/http.dart' as http;
import 'package:wonders/logic/common/json_prefs_file.dart';
import 'package:wonders/logic/common/remote_json_loader.dart';
import 'package:wonders/main.dart';
import 'package:wonders/logic/config.dart';

class UnsplashRepo {
  static const String _cacheKey = 'resume_unsplash_cache_v1';
  final JsonPrefsFile _cacheFile = JsonPrefsFile(_cacheKey);

  Future<Map<String, dynamic>> fetchRemote() async {
    final response = await http.get(
      Uri.parse(UploadConfig.remoteUrlFor(UploadConfig.unsplashKey)),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode} while loading ${UploadConfig.unsplashKey}',
      );
    }
    final bytes = response.bodyBytes;
    final data = _decode(bytes);
    await _cacheFile.save(data);
    return data;
  }

  Future<Map<String, dynamic>> loadPreferred() async {
    final data = await RemoteJsonLoader.loadJson(
      key: UploadConfig.unsplashKey,
      cacheKey: _cacheKey,
      assetPath: 'assets/data/resume_unsplash.json',
    );
    return _normalize(data);
  }

  Future<void> saveAll(Map<String, dynamic> data) async {
    await _persist(data);
  }

  Future<void> updateVisibility(dynamic id, bool isPublic) async {
    final data = await fetchRemote();
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    bool updated = false;
    for (final item in items) {
      if (item['id'].toString() == id.toString()) {
        item['isPublic'] = isPublic;
        updated = true;
        break;
      }
    }
    if (!updated) {
      throw Exception('未找到图片 (id=$id)');
    }
    await _persist(data);
  }

  Future<Map<String, dynamic>> deleteEntry(dynamic id) async {
    final data = await fetchRemote();
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic>? target;
    items.removeWhere((item) {
      final match = item['id'].toString() == id.toString();
      if (match) target = item;
      return match;
    });
    if (target == null) {
      throw Exception('未找到图片 (id=$id)');
    }

    final path = target!['imagePath']?.toString();
    if (path != null && path.isNotEmpty) {
      try {
        await Amplify.Storage.remove(
          path: amplify_core.StoragePath.fromString(path),
        ).result;
      } catch (e) {
        debugPrint('删除图片文件失败: $e');
      }
    }

    await _persist(data);
    return fetchRemote();
  }

  Map<String, dynamic> _decode(List<int> bytes) {
    final jsonString = utf8.decode(bytes);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return _normalize(data);
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> source) {
    final data = Map<String, dynamic>.from(source);
    final items = (data['items'] as List?) ?? const [];
    data['items'] = items.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final imagePath = map['imagePath']?.toString();
      if (imagePath != null && imagePath.isNotEmpty) {
        if (imagePath.contains('unsplash_data/')) {
          map['imagePath'] = imagePath.replaceFirst(
            'unsplash_data/',
            'public/photos/',
          );
        } else if (imagePath.contains('photos/') &&
            !imagePath.startsWith('public/')) {
          map['imagePath'] = 'public/$imagePath';
        } else if (!imagePath.contains('/')) {
          map['imagePath'] = 'public/photos/$imagePath';
        }
      }
      if (map['isPublic'] is! bool) {
        map['isPublic'] = true;
      }
      return map;
    }).toList(growable: true);
    return data;
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    final payload = jsonEncode(data);
    await Amplify.Storage.uploadData(
      path: amplify_core.StoragePath.fromString(UploadConfig.unsplashKey),
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
    unsplashLogic.notifyDataChanged();
  }
}
