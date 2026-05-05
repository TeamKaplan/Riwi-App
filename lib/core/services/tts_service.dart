import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("es-ES"); // Español por defecto
      await _flutterTts.setSpeechRate(0.5); // Velocidad normal
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint("Error inicializando TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
