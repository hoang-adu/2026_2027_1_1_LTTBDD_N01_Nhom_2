import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flashcard_app/core/services/tts_service.dart';

class FakeFlutterTts implements FlutterTts {
  final List<String> calls = [];
  final Map<String, Object> failures = {};

  /// true: trả về Future lỗi; false: ném lỗi ngay
  bool failAsync = false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = RegExp(r'"(.*)"')
        .firstMatch(invocation.memberName.toString())!
        .group(1)!;
    final args = invocation.positionalArguments;
    calls.add(args.isEmpty ? name : '$name:${args.join(',')}');

    final error = failures[name];
    if (error != null) {
      if (failAsync) return Future<dynamic>.error(error);
      throw error;
    }
    return Future<dynamic>.value(1);
  }
}

void main() {
  late FakeFlutterTts fake;
  late TtsService service;

  setUp(() {
    fake = FakeFlutterTts();
    service = TtsService(engine: fake);
  });

  group('speak', () {
    test('khởi tạo một lần, sau đó dừng câu cũ, đặt ngôn ngữ và đọc', () async {
      await service.speak('hello');
      expect(fake.calls, [
        'setVolume:1.0',
        'setSpeechRate:0.45',
        'setPitch:1.0',
        'stop',
        'setLanguage:en-US',
        'speak:hello',
      ]);

      // Lần đọc thứ hai không khởi tạo lại.
      fake.calls.clear();
      await service.speak('world');
      expect(fake.calls, ['stop', 'setLanguage:en-US', 'speak:world']);
    });

    test('dùng ngôn ngữ được truyền vào', () async {
      await service.speak('xin chào', lang: 'vi-VN');
      expect(fake.calls, contains('setLanguage:vi-VN'));
    });

    test('dùng tốc độ đọc tùy chỉnh', () async {
      service = TtsService(engine: fake, speechRate: 0.6);
      await service.speak('hello');
      expect(fake.calls, contains('setSpeechRate:0.6'));
    });

    test('cắt khoảng trắng đầu/cuối', () async {
      await service.speak('  hello  ');
      expect(fake.calls.last, 'speak:hello');
    });

    test('văn bản rỗng hoặc toàn khoảng trắng thì không gọi engine', () async {
      await service.speak('');
      await service.speak('   ');
      expect(fake.calls, isEmpty);
    });

    test('đọc liên tiếp: mỗi lần đều dừng câu trước', () async {
      await service.speak('one');
      await service.speak('two');
      expect(fake.calls.where((c) => c == 'stop').length, 2);
      expect(fake.calls.last, 'speak:two');
    });
  });

  group('stop', () {
    test('gọi stop của engine', () async {
      await service.stop();
      expect(fake.calls, ['stop']);
    });
  });

  group('lỗi platform không được ném ra ngoài (NFR07)', () {
    final errors = <String, Object>{
      'PlatformException': PlatformException(code: 'error', message: 'no engine'),
      'MissingPluginException': MissingPluginException('no plugin'),
      'StateError': StateError('boom'),
    };

    const ops = [
      'stop',
      'setLanguage',
      'setSpeechRate',
      'setVolume',
      'setPitch',
      'speak',
    ];

    for (final op in ops) {
      for (final asyncFail in [false, true]) {
        for (final entry in errors.entries) {
          final mode = asyncFail ? 'async' : 'sync';
          test('speak không ném ${entry.key} khi $op lỗi ($mode)', () async {
            fake
              ..failAsync = asyncFail
              ..failures[op] = entry.value;
            await expectLater(service.speak('hello'), completes);
          });
        }
      }
    }

    for (final asyncFail in [false, true]) {
      test('stop không ném lỗi (${asyncFail ? 'async' : 'sync'})', () async {
        fake
          ..failAsync = asyncFail
          ..failures['stop'] = PlatformException(code: 'error');
        await expectLater(service.stop(), completes);
      });
    }

    test('stop lỗi thì speak vẫn thử đọc tiếp', () async {
      fake.failures['stop'] = PlatformException(code: 'error');
      await service.speak('hello');
      expect(fake.calls, contains('speak:hello'));
    });
  });

  test('instance là singleton', () {
    expect(identical(TtsService.instance, TtsService.instance), isTrue);
  });
}