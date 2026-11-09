import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Đọc phát âm bằng flutter_tts (singleton, không phải Provider).
class TtsService {
  TtsService._() {
    _initTts();
  }

  static final TtsService instance = TtsService._();

  late final FlutterTts _flutterTts = FlutterTts();

  Future<void> _initTts() async {
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5); // Tốc độ đọc chuẩn cho học từ vựng
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      // Nuốt lỗi khởi tạo, ghi log để debug không làm crash app
      debugPrint('TtsService init error: $e');
    }
  }

  Future<void> speak(String text, {String lang = 'en-US'}) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.setLanguage(lang);
      await _flutterTts.stop(); // Dừng câu đang đọc trước đó
      await _flutterTts.speak(text);
    } catch (e) {
      // Nuốt lỗi phát âm, đảm bảo app vẫn chạy bình thường nếu thiết bị lỗi TTS
      debugPrint('TtsService speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      // Nuốt lỗi stop
      debugPrint('TtsService stop error: $e');
    }
  }
}