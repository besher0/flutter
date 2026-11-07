import 'dart:ui';

import 'package:coursaty_student_and_teacher/services/crash_reporting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSink implements CrashSink {
  bool? collectionEnabled;
  final errors = <({Object error, String? reason, bool fatal})>[];
  final logs = <String>[];
  final keys = <String, Object>{};

  @override
  Future<void> setCollectionEnabled(bool enabled) async =>
      collectionEnabled = enabled;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async => errors.add((error: error, reason: reason, fatal: fatal));

  @override
  Future<void> log(String message) async => logs.add(message);

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      keys[key] = value;
}

void main() {
  late FlutterExceptionHandler? originalFlutterHandler;
  late ErrorCallback? originalPlatformHandler;

  setUp(() {
    originalFlutterHandler = FlutterError.onError;
    originalPlatformHandler = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = originalFlutterHandler;
    PlatformDispatcher.instance.onError = originalPlatformHandler;
    CrashReporting.resetForTesting();
  });

  test('debug builds collect nothing and install no handlers', () async {
    final sink = _FakeSink();
    final before = FlutterError.onError;
    await CrashReporting.init(sink: sink, collect: false);

    expect(sink.collectionEnabled, isFalse);
    expect(CrashReporting.isEnabled, isFalse);
    expect(FlutterError.onError, same(before));
    CrashReporting.log('ignored');
    expect(sink.logs, isEmpty);
  });

  test('a framework error is reported as non-fatal and still shown', () async {
    final sink = _FakeSink();
    final shown = <FlutterErrorDetails>[];
    FlutterError.onError = shown.add;
    await CrashReporting.init(sink: sink, collect: true);

    final details = FlutterErrorDetails(exception: StateError('overflow'));
    FlutterError.onError!(details);
    await Future<void>.delayed(Duration.zero);

    expect(sink.errors.single.fatal, isFalse);
    expect(sink.errors.single.error, isA<StateError>());
    expect(shown, [details]);
  });

  test('an error no zone handled is reported as fatal', () async {
    final sink = _FakeSink();
    await CrashReporting.init(sink: sink, collect: true);

    final handled = PlatformDispatcher.instance.onError!(
      ArgumentError('boom'),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(handled, isTrue);
    expect(sink.errors.single.fatal, isTrue);
  });

  test('breadcrumbs, handled errors and keys go to the sink', () async {
    final sink = _FakeSink();
    await CrashReporting.init(sink: sink, collect: true);

    CrashReporting.log('player: open online quality=720p');
    CrashReporting.recordError(
      StateError('x'),
      StackTrace.current,
      reason: 'player init',
    );
    CrashReporting.setCustomKey('role', 'student');
    await Future<void>.delayed(Duration.zero);

    expect(sink.logs, ['player: open online quality=720p']);
    expect(sink.errors.single.reason, 'player init');
    expect(sink.errors.single.fatal, isFalse);
    expect(sink.keys, {'role': 'student'});
  });

  test('a sink that fails to start leaves reporting off', () async {
    await CrashReporting.init(sink: _FailingSink(), collect: true);
    expect(CrashReporting.isEnabled, isFalse);
  });
}

class _FailingSink extends _FakeSink {
  @override
  Future<void> setCollectionEnabled(bool enabled) async =>
      throw StateError('no Firebase');
}
