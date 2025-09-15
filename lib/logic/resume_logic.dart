import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/resume_data.dart';
import 'package:wonders/logic/data/resume_type.dart';
import 'package:wonders/logic/data/resume_data/anshex_exp_data.dart';
import 'package:wonders/logic/data/resume_data/changjiang_exp_data.dart';
import 'package:wonders/logic/data/resume_data/raytec_exp_data.dart';
import 'package:wonders/logic/data/resume_data/weic1_exp_data.dart';
import 'package:wonders/logic/data/resume_data/weic2_exp_data.dart';
import 'package:wonders/logic/data/resume_data/cmn_exp_data.dart';
import 'package:wonders/logic/data/resume_data/self_exp_data.dart';
import 'package:wonders/logic/data/resume_data/kaisei_exp_data.dart';
import 'package:wonders/logic/data/wonders_data/search/search_data.dart';
import 'package:wonders/logic/data/lawyer_data.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class ResumeLogic {
  List<ResumeData> all = [];

  final int timelineStartYear = 2000;
  final int timelineEndYear = 2030;

  ResumeData getData(ResumeType value) {
    ResumeData? result = all.firstWhereOrNull((w) {
      return w.type == value;
    });

    if (result == null) throw ('Could not find data for resume type $value');

    return result;
  }

  Future <Map<int, String>> getResumeEventData() async {
    final jsonString = await rootBundle.loadString('assets/data/resume_events.json');
    final jsonData = jsonDecode(jsonString);
    final events = Map<int, String>.from(jsonData.map((key, value) => MapEntry(int.parse(key), value)));

    return events;
  }

  Future<List<LawyerInfo>?> fetchLawyerAvatar() async {
    const apiUrl = 'https://legalai.co.jp/api/lawyersbycompanyid?company_id=C-001&is_verified=false';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final lawyers = jsonData['lawyers'];
        if (lawyers != null && lawyers.isNotEmpty) {
          final List<LawyerInfo> lawyersInfo = [];
          for(var lawyer in lawyers) {
              final avatarImage = lawyer['lawyer_avatar'];
              final avatarAnimations = lawyer['lawyer_ai_avatar_animations'];
              lawyersInfo.add(LawyerInfo(avatarImage, avatarAnimations));
          }
          return lawyersInfo;
        }
      }
      // If the response status code is not 200 or lawyers list is empty, return null.
      return null;
    } catch (e) {
      // If an error occurs during API call, return null.
      return null;
    }
  }

  Future <List<SearchData>> getResumePresentationData() async {
    final jsonString = await rootBundle.loadString('assets/data/resume_presentation.json');
    final jsonData = jsonDecode(jsonString);
    List<SearchData> searchList = [];

    final parsed = jsonData["items"].cast<Map<String, dynamic>>();
    searchList = parsed.map<SearchData>((Map<String, dynamic> item) {
      return SearchData(
        item['year'],
        item['id'],
        item['type'],
        item['title'],
        item['keywords'],
        item['imagePath'],
        item['aspectRatio'].toDouble(),
      );
    }).toList();

    return searchList;
  }

  Future <List<String>> getResumePresentationSuggestions() async {
    final jsonString = await rootBundle.loadString('assets/data/resume_presentation.json');
    final jsonData = jsonDecode(jsonString);

    final suggestions = List<String>.from(jsonData['suggestions']);
    return suggestions;
  }

  Future<void> init() async {
    // Read and decode the JSON file
    final jsonString = await rootBundle.loadString('assets/data/resume_timeline.json');
    final jsonData = jsonDecode(jsonString);

    all = [
      AnshexExpData(jsonData),
      ChangjiangExpData(jsonData),
      RaytecExpData(jsonData),
      Weic1ExpData(jsonData),
      Weic2ExpData(jsonData),
      SelfExpData(jsonData),
      CmnExpData(jsonData),
      KaiseiExpData(jsonData)
    ];
  }
}
