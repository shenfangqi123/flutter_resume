import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wonders/logic/config.dart';
import 'package:wonders/logic/common/json_prefs_file.dart';

class RemoteJsonLoader {
  RemoteJsonLoader._();

  static Future<Map<String, dynamic>> loadJson({
    required String key,
    required String cacheKey,
    required String assetPath,
  }) async {
    final cache = JsonPrefsFile(cacheKey);

    try {
      final response =
          await http.get(Uri.parse(UploadConfig.remoteUrlFor(key)));
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode} while loading ${UploadConfig.remoteUrlFor(key)}',
        );
      }
      final bytes = response.bodyBytes;
      final map = _decode(bytes);
      await cache.save(map);
      return map;
    } catch (e, st) {
      debugPrint('Failed to load remote json ($key): $e\n$st');
    }

    try {
      final cached = await cache.load();
      if (cached.isNotEmpty) {
        return Map<String, dynamic>.from(cached);
      }
    } catch (e, st) {
      debugPrint('Failed to load cached json ($cacheKey): $e\n$st');
    }

    final assetString = await rootBundle.loadString(assetPath);
    final assetData = jsonDecode(assetString) as Map<String, dynamic>;
    return assetData;
  }

  static Map<String, dynamic> _decode(List<int> bytes) {
    final jsonString = utf8.decode(bytes);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data;
  }
}
