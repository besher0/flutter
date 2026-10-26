import 'dart:convert';
import 'dart:io';

import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/online_playback_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for Bunny (path token) and the edge gateway (session header).
class _FakeCdn {
  _FakeCdn(this.server);

  final HttpServer server;
  final requests = <HttpRequest>[];

  /// Only this token / header is accepted; a renewal changes it.
  String validToken = 'bcdn_token=A&expires=1&token_path=%2Fvid%2F';
  String? validHeader;

  static Future<_FakeCdn> start() async {
    final cdn = _FakeCdn(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    cdn.server.listen(cdn._handle);
    return cdn;
  }

  String get origin => 'http://127.0.0.1:${server.port}';

  Future<void> _handle(HttpRequest request) async {
    requests.add(request);
    final segments = request.uri.path.split('/')..removeAt(0);
    final header = request.headers.value('x-coursaty-playback-session');
    final authorized = validHeader != null
        ? header == validHeader
        : segments.isNotEmpty && segments.first == validToken;
    if (!authorized) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }
    final path = validHeader != null ? segments : segments.sublist(1);
    final name = path.join('/');
    if (name == 'vid/playlist.m3u8') {
      request.response.headers.contentType = ContentType(
        'application',
        'vnd.apple.mpegurl',
      );
      request.response.write(
        '#EXTM3U\n'
        '#EXT-X-KEY:METHOD=AES-128,URI="$origin/$validToken/vid/key.bin"\n'
        '#EXTINF:4,\n'
        'video0.ts\n'
        '#EXTINF:4,\n'
        '$origin/$validToken/vid/video1.ts\n'
        '#EXT-X-ENDLIST',
      );
    } else {
      request.response.headers.contentType = ContentType('video', 'mp2t');
      request.response.add(utf8.encode('bytes of $name'));
    }
    await request.response.close();
  }
}

Future<(int, String)> _get(Uri uri) async {
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(uri)).close();
    return (response.statusCode, await utf8.decodeStream(response));
  } finally {
    client.close();
  }
}

void main() {
  late _FakeCdn cdn;
  late OnlinePlaybackProxy proxy;

  setUp(() async => cdn = await _FakeCdn.start());
  tearDown(() async {
    await proxy.close();
    await cdn.server.close(force: true);
  });

  test('the player keeps one local URL while a renewal swaps the Bunny token', () async {
    final signed = Uri.parse('${cdn.origin}/${cdn.validToken}/vid/playlist.m3u8');
    proxy = await OnlinePlaybackProxy.start(upstream: signed);
    final local = proxy.localUrlFor(signed);
    expect(local.host, '127.0.0.1');
    expect(local.toString(), isNot(contains('bcdn_token')));

    final (status, playlist) = await _get(local);
    expect(status, 200);
    // Absolute references come back to the proxy, without the token.
    expect(playlist, isNot(contains('bcdn_token')));
    expect(playlist, isNot(contains(cdn.origin)));
    final segment = local.resolve('video0.ts');
    expect(await _get(segment), (200, 'bytes of vid/video0.ts'));

    // Renewal: the old token stops working, the player URL does not change.
    cdn.validToken = 'bcdn_token=B&expires=2&token_path=%2Fvid%2F';
    final renewed = Uri.parse('${cdn.origin}/${cdn.validToken}/vid/playlist.m3u8');
    proxy.updateUpstream(renewed, const {});
    expect(proxy.localUrlFor(renewed), local);
    expect(await _get(local.resolve('video1.ts')), (200, 'bytes of vid/video1.ts'));
    expect(cdn.requests.last.uri.path, '/${cdn.validToken}/vid/video1.ts');
  });

  test('gateway sessions travel as a header that a renewal replaces', () async {
    cdn.validHeader = 'session-1';
    final gateway = Uri.parse('${cdn.origin}/vid/playlist.m3u8');
    proxy = await OnlinePlaybackProxy.start(
      upstream: gateway,
      headers: const {'X-Coursaty-Playback-Session': 'session-1'},
    );
    final local = proxy.localUrlFor(gateway);
    expect((await _get(local)).$1, 200);

    cdn.validHeader = 'session-2';
    proxy.updateUpstream(gateway, const {
      'X-Coursaty-Playback-Session': 'session-2',
    });
    expect(await _get(local.resolve('video0.ts')), (200, 'bytes of vid/video0.ts'));
  });

  test('only requests carrying the random local secret are served', () async {
    final signed = Uri.parse('${cdn.origin}/${cdn.validToken}/vid/playlist.m3u8');
    proxy = await OnlinePlaybackProxy.start(upstream: signed);
    final local = proxy.localUrlFor(signed);
    final guessed = local.replace(path: '/wrong/vid/playlist.m3u8');
    expect((await _get(guessed)).$1, HttpStatus.forbidden);
    expect(cdn.requests, isEmpty);
  });

  test('a refused upstream answer reaches the player so it can recover', () async {
    final signed = Uri.parse('${cdn.origin}/${cdn.validToken}/vid/playlist.m3u8');
    proxy = await OnlinePlaybackProxy.start(upstream: signed);
    cdn.validToken = 'bcdn_token=EXPIRED-ELSEWHERE';
    expect((await _get(proxy.localUrlFor(signed))).$1, HttpStatus.forbidden);
  });

  test('playlist rewriting keeps relative references and query strings', () {
    final text = OnlinePlaybackProxy.rewritePlaylist(
      '#EXTM3U\n'
      '#EXT-X-MAP:URI="init.mp4"\n'
      'https://vz.b-cdn.net/bcdn_token=x&expires=1/vid/720p/video.m3u8?v=2&token=t\n'
      '480p/video.m3u8',
      'secret',
    );
    expect(
      text.split('\n'),
      [
        '#EXTM3U',
        '#EXT-X-MAP:URI="init.mp4"',
        '/secret/vid/720p/video.m3u8?v=2',
        '480p/video.m3u8',
      ],
    );
  });
}
