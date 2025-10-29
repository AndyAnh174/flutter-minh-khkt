import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, {String language = 'vi-VN'}) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }
}


