import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Đọc phát âm bằng flutter_tts (singleton, không phải Provider).
/// Mọi lỗi platform bị bắt và ghi log, không làm crash app
class TtsService {
  /// [engine] cho phép truyền FlutterTts giả khi test; bỏ trống thì dùng engine thật.
  // ignore: prefer_initializing_formals
  TtsService({FlutterTts? engine, this.speechRate = 0.45}) : _engine = engine;

  static final TtsService instance = TtsService();

  /// Tốc độ đọc chuẩn cho học từ vựng.
  final double speechRate;

  FlutterTts? _engine;
  FlutterTts get _flutterTts => _engine ??= FlutterTts();

  // Khởi tạo một lần, ở lần đọc đầu tiên.
  Future<void>? _initFuture;
  Future<void> _ensureInit() => _initFuture ??= _initTts();

  Future<void> _initTts() async {
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      // Nuốt lỗi khởi tạo, chỉ ghi log để app không crash
      debugPrint('TtsService init error: $e');
    }
  }

  Future<void> speak(String text, {String lang = 'en-US'}) async {
    final content = text.trim();
    if (content.isEmpty) return;

    await _ensureInit();
    await stop(); // Dừng câu đang đọc; nếu stop lỗi vẫn đọc tiếp

    try {
      await _flutterTts.setLanguage(lang);
      await _flutterTts.speak(content);
    } catch (e) {
      // Nuốt lỗi phát âm, app vẫn chạy bình thường nếu thiết bị lỗi TTS
      debugPrint('TtsService speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TtsService stop error: $e');
    }
  }
}