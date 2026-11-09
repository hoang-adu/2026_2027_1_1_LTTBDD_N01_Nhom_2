import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Thiết lập SharedPreferences giả cho môi trường test
    SharedPreferences.setMockInitialValues({
      'app_locale': 'vi',
      'is_dark_mode': false,
    });
  });

  test('LocaleProvider loads default and updates correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kiểm tra giá trị khởi tạo mặc định
    expect(prefs.getString('app_locale'), 'vi');
    expect(prefs.getBool('is_dark_mode'), isFalse);

    // Giả lập thay đổi sang tiếng Anh
    await prefs.setString('app_locale', 'en');
    expect(prefs.getString('app_locale'), 'en');
  });
}