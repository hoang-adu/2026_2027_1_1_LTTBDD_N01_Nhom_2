/// Đọc phát âm bằng flutter_tts (singleton, không phải Provider). [Đạt]
/// Lỗi TTS phải được nuốt/ghi log, không crash.
// TODO(dat): khởi tạo FlutterTts và cài đặt speak/stop.
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  Future<void> speak(String text, {String lang = 'en-US'}) async {}

  Future<void> stop() async {}
}
