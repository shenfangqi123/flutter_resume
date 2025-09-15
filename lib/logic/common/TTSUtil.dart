import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class TTSUtil {
  static const _apikey = 'AIzaSyDotMOZochS0mtPIIUVOIvzI0nMtDdQ_kU';
  static AudioPlayer audioPlayer = AudioPlayer();

  static String voice = 'ja-JP-Standard-A';

  static String lastFileName = '';

  static Future<http.Response> texttospeech(String text, String voicetype) {
    String url =
        'https://texttospeech.googleapis.com/v1beta1/text:synthesize?key=$_apikey';

    var body = json.encode({
      'audioConfig': {
        'audioEncoding': 'LINEAR16',
        'pitch': 0,
        'speakingRate': 1
      },
      "input": {"text": text},
      'voice': {'languageCode': 'cmn-CN', 'name': voicetype}
    });

    var response = http.post(Uri.parse(url),
        headers: {'Content-type': 'application/json'}, body: body);

    return response;
  }

// Play male voice
  static void playVoice(String text) async {
    var response = await texttospeech(text, voice);
    var jsonData = jsonDecode(response.body);

    String audioBase64 = jsonData['audioContent'] ?? '';

    if (audioBase64.isNotEmpty) {
      Uint8List bytes = base64Decode(audioBase64);

      String dir = (await getApplicationDocumentsDirectory()).path;

      // 删除上一次的文件
      if (lastFileName != '') {
        File oldFile = File("$dir/$lastFileName");
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      DateTime now = DateTime.now();
      lastFileName = 'tts_${now.millisecondsSinceEpoch}.mp3';
      File file = File("$dir/$lastFileName");

      await file.writeAsBytes(bytes);

      await audioPlayer.stop();
      await audioPlayer.play(DeviceFileSource(file.path));
      audioPlayer.setPlaybackRate(1);
      audioPlayer.setVolume(1);
    }
  }

  static void stop() {
    audioPlayer.stop();
  }
}
