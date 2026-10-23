import 'dart:io';
import 'dart:typed_data';

import 'package:coursaty_student_and_teacher/features/course_content_management/data/services/resumable_video_upload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:tusc/tusc.dart' hide Headers;

/// A minimal TUS server: it cuts the connection in the middle of the second
/// chunk, then answers 409 (upload locked) to the next two requests, like a
/// server that has not noticed the dropped connection yet.
class _TusServer {
  late final HttpServer _server;
  final received = BytesBuilder();
  var patches = 0;
  var lockedAnswers = 2;
  var dropDone = false;

  String get url => 'http://127.0.0.1:${_server.port}/tusupload';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final response = request.response..headers.set('Tus-Resumable', '1.0.0');
    if (request.method == 'POST') {
      response
        ..statusCode = 201
        ..headers.set('Location', '$url/video-1');
      return response.close();
    }
    if (dropDone && lockedAnswers > 0) {
      lockedAnswers--;
      await request.drain<void>();
      response.statusCode = 409;
      return response.close();
    }
    if (request.method == 'HEAD') {
      response.headers.set('Upload-Offset', '${received.length}');
      return response.close();
    }
    // PATCH
    patches++;
    if (patches == 2 && !dropDone) {
      dropDone = true;
      final socket = await request.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    await for (final bytes in request) {
      received.add(bytes);
    }
    response
      ..statusCode = 204
      ..headers.set('Upload-Offset', '${received.length}');
    return response.close();
  }
}

void main() {
  test(
    'pressing resume after a dropped connection finishes the same upload',
    () async {
      final server = _TusServer();
      await server.start();
      addTearDown(server.close);

      final dir = await Directory.systemTemp.createTemp('tus_upload_test');
      addTearDown(() => dir.delete(recursive: true));
      final content = Uint8List.fromList(
        List.generate(5 * 1024, (i) => i % 251),
      );
      final file = File('${dir.path}/video.mp4')..writeAsBytesSync(content);

      final upload = ResumableVideoUpload(
        headers: const {},
        refreshHeaders: () async => null,
        resumeRetryDelays: const [
          Duration(milliseconds: 50),
          Duration(milliseconds: 50),
          Duration(milliseconds: 50),
        ],
        createClient: ({required uploadUrl, required headers}) => TusClient(
          url: server.url,
          uploadUrl: uploadUrl,
          file: XFile(file.path),
          headers: headers,
          chunkSize: 1024,
          timeout: const Duration(seconds: 5),
          httpClient: IOClient(
            HttpClient()..connectionTimeout = const Duration(seconds: 5),
          ),
        ),
      );

      final progress = <double>[];
      // The connection drops during the second chunk: the upload pauses.
      expect(
        await upload.run(onProgress: progress.add),
        VideoUploadOutcome.failed,
      );
      expect(server.received.length, 1024);

      // Resume: the server still answers 409 twice, then accepts the rest.
      expect(
        await upload.run(onProgress: progress.add),
        VideoUploadOutcome.completed,
      );
      expect(server.lockedAnswers, 0);
      expect(server.received.takeBytes(), content);
      expect(progress.last, 100);
    },
  );
}
