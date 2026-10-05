import 'dart:typed_data';

import 'package:coursaty_student_and_teacher/features/subscriptions/data/services/qr_image_saver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('downloads QR bytes and writes them to the gallery', () async {
    Uint8List? savedBytes;
    String? savedName;
    final saver = QrImageSaver(
      fetchBytes: (url) async {
        expect(url, 'https://example.test/qr.webp');
        return Uint8List.fromList([1, 2, 3]);
      },
      galleryWriter: (bytes, {required name}) async {
        savedBytes = bytes;
        savedName = name;
      },
    );

    await saver.saveFromUrl(
      url: 'https://example.test/qr.webp',
      fileName: 'coursaty_qr_course-1',
    );

    expect(savedBytes, orderedEquals([1, 2, 3]));
    expect(savedName, 'coursaty_qr_course-1');
  });

  test('rejects an empty QR response without writing to the gallery', () async {
    var writeCalls = 0;
    final saver = QrImageSaver(
      fetchBytes: (_) async => Uint8List(0),
      galleryWriter: (_, {required name}) async => writeCalls++,
    );

    expect(
      () => saver.saveFromUrl(
        url: 'https://example.test/qr.webp',
        fileName: 'coursaty_qr_course-1',
      ),
      throwsA(
        isA<QrImageSaveException>().having(
          (error) => error.failure,
          'failure',
          QrImageSaveFailure.unsupportedFormat,
        ),
      ),
    );
    expect(writeCalls, 0);
  });

  test('maps a fetch failure to a network save failure', () async {
    final saver = QrImageSaver(
      fetchBytes: (_) async => throw StateError('offline'),
      galleryWriter: (_, {required name}) async {},
    );

    expect(
      () => saver.saveFromUrl(
        url: 'https://example.test/qr.webp',
        fileName: 'coursaty_qr_course-1',
      ),
      throwsA(
        isA<QrImageSaveException>().having(
          (error) => error.failure,
          'failure',
          QrImageSaveFailure.network,
        ),
      ),
    );
  });
}
