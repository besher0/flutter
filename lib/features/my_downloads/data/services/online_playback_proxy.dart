import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

/// Local HTTP proxy between the player and the online HLS stream.
///
/// A playback session expires (signed Bunny URLs after about five minutes,
/// gateway sessions after ten), and renewing it used to call
/// `setupDataSource` with the new URL. better_player answers that by removing
/// the video until the next play event, so the picture went black for a moment
/// at every renewal. Through this proxy the player keeps one local URL for the
/// whole viewing; a renewal only swaps the upstream credentials
/// ([updateUpstream]) and the next request uses them.
///
/// Upstream credentials are either a path token (Bunny's
/// `/bcdn_token=…&expires=…/` first path segment) or request headers (the
/// edge gateway's session header). Playlists are passed through with absolute
/// references rewritten to local paths, like the gateway itself does, so every
/// request comes back here.
class OnlinePlaybackProxy {
  OnlinePlaybackProxy._(this._server, this._secret, this._client);

  static const _tokenSegmentPrefix = 'bcdn_token=';
  static const _tokenQueryKeys = {'token', 'expires', 'token_path', 'bcdn_token'};

  final HttpServer _server;
  final String _secret;
  final HttpClient _client;
  late _Upstream _upstream;

  /// Bumped by every [updateUpstream], so a request refused with credentials
  /// that were replaced meanwhile is retried once with the new ones.
  int _generation = 0;
  bool _closed = false;

  static Future<OnlinePlaybackProxy> start({
    required Uri upstream,
    Map<String, String> headers = const {},
    HttpClient? client,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final proxy = OnlinePlaybackProxy._(
      server,
      _randomSecret(),
      client ?? (HttpClient()..connectionTimeout = const Duration(seconds: 20)),
    );
    proxy._upstream = _Upstream.parse(upstream, headers);
    server.listen(proxy._handle);
    return proxy;
  }

  /// The local URL the player opens for [upstream] (the playlist).
  Uri localUrlFor(Uri upstream) {
    final parsed = _Upstream.parse(upstream, const {});
    return Uri.parse(
      'http://127.0.0.1:${_server.port}/$_secret${parsed.path}'
      '${parsed.query.isEmpty ? '' : '?${parsed.query}'}',
    );
  }

  /// Uses the renewed session for every request from now on.
  void updateUpstream(Uri upstream, Map<String, String> headers) {
    _upstream = _Upstream.parse(upstream, headers);
    _generation++;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _server.close(force: true);
    _client.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      final segments = request.uri.path.split('/');
      // ['', secret, ...path]
      if (segments.length < 3 || segments[1] != _secret) {
        response.statusCode = HttpStatus.forbidden;
        await response.close();
        return;
      }
      if (request.method != 'GET' && request.method != 'HEAD') {
        response.statusCode = HttpStatus.methodNotAllowed;
        await response.close();
        return;
      }
      final path = '/${segments.skip(2).join('/')}';
      final generation = _generation;
      var upstream = await _send(request, path);
      final refused =
          upstream.statusCode == HttpStatus.unauthorized ||
          upstream.statusCode == HttpStatus.forbidden;
      if (refused && generation != _generation) {
        // The session was renewed while this request was on its way.
        await upstream.drain<void>();
        upstream = await _send(request, path);
      }
      await _forward(request, path, upstream);
    } catch (error) {
      // The player cancels requests it no longer needs (seek, quality
      // change); a closed local connection is normal.
      developer.log(
        'proxy request failed: ${error.runtimeType}',
        name: 'OnlinePlaybackProxy',
      );
      try {
        response.statusCode = HttpStatus.badGateway;
      } catch (_) {}
      try {
        await response.close();
      } catch (_) {}
    }
  }

  Future<HttpClientResponse> _send(HttpRequest request, String path) async {
    final upstream = _upstream;
    final query = request.uri.query;
    final outgoing = await _client.openUrl(
      request.method,
      upstream.resolve(path, query),
    );
    outgoing.followRedirects = true;
    upstream.headers.forEach(outgoing.headers.set);
    outgoing.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    final range = request.headers.value(HttpHeaders.rangeHeader);
    if (range != null) outgoing.headers.set(HttpHeaders.rangeHeader, range);
    return outgoing.close();
  }

  Future<void> _forward(
    HttpRequest request,
    String path,
    HttpClientResponse upstream,
  ) async {
    final response = request.response;
    response.statusCode = upstream.statusCode;
    final contentType = upstream.headers.contentType;
    if (contentType != null) response.headers.contentType = contentType;
    for (final name in const [
      HttpHeaders.contentRangeHeader,
      HttpHeaders.acceptRangesHeader,
    ]) {
      final value = upstream.headers.value(name);
      if (value != null) response.headers.set(name, value);
    }

    final isPlaylist =
        upstream.statusCode == HttpStatus.ok &&
        (path.toLowerCase().endsWith('.m3u8') ||
            (contentType?.subType.toLowerCase().contains('mpegurl') ?? false));
    if (isPlaylist) {
      final text = await utf8.decodeStream(upstream);
      final local = utf8.encode(rewritePlaylist(text, _secret));
      response.headers.contentLength = local.length;
      if (request.method != 'HEAD') response.add(local);
      await response.close();
      return;
    }
    if (upstream.contentLength >= 0 &&
        upstream.compressionState == HttpClientResponseCompressionState.notCompressed) {
      response.headers.contentLength = upstream.contentLength;
    }
    if (request.method == 'HEAD') {
      await upstream.drain<void>();
    } else {
      await response.addStream(upstream);
    }
    await response.close();
  }

  /// Rewrites absolute references in a playlist to local paths under
  /// [secret], dropping Bunny's path token and token query parameters.
  /// Relative references already resolve to the proxy and are kept.
  static String rewritePlaylist(String text, String secret) {
    String local(String absolute) {
      final uri = Uri.parse(absolute);
      final parsed = _Upstream.parse(uri, const {});
      return '/$secret${parsed.path}'
          '${parsed.query.isEmpty ? '' : '?${parsed.query}'}';
    }

    bool isAbsolute(String value) =>
        value.startsWith('http://') || value.startsWith('https://');

    return const LineSplitter()
        .convert(text)
        .map((line) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) return line;
          if (trimmed.startsWith('#')) {
            return line.replaceAllMapped(
              RegExp(r'URI="([^"]+)"'),
              (match) => isAbsolute(match[1]!)
                  ? 'URI="${local(match[1]!)}"'
                  : match[0]!,
            );
          }
          return isAbsolute(trimmed) ? local(trimmed) : line;
        })
        .join('\n');
  }

  static String _randomSecret() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}

/// Where requests go: origin, optional Bunny path token and headers, plus the
/// token-free path and query of the URL it was parsed from.
class _Upstream {
  _Upstream({
    required this.origin,
    required this.tokenSegment,
    required this.headers,
    required this.path,
    required this.query,
  });

  /// Works on the encoded path, so the token segment (which contains an
  /// encoded `token_path`) is copied byte for byte.
  factory _Upstream.parse(Uri uri, Map<String, String> headers) {
    final segments = uri.path.split('/').where((s) => s.isNotEmpty).toList();
    String? token;
    if (segments.isNotEmpty &&
        segments.first.startsWith(OnlinePlaybackProxy._tokenSegmentPrefix)) {
      token = segments.removeAt(0);
    }
    final query = uri.query
        .split('&')
        .where((pair) {
          if (pair.isEmpty) return false;
          final key = pair.split('=').first;
          return !OnlinePlaybackProxy._tokenQueryKeys.contains(key);
        })
        .join('&');
    return _Upstream(
      origin: uri.hasPort
          ? '${uri.scheme}://${uri.host}:${uri.port}'
          : '${uri.scheme}://${uri.host}',
      tokenSegment: token,
      headers: Map.unmodifiable(headers),
      path: '/${segments.join('/')}',
      query: query,
    );
  }

  final String origin;
  final String? tokenSegment;
  final Map<String, String> headers;
  final String path;
  final String query;

  Uri resolve(String path, String query) => Uri.parse(
    '$origin${tokenSegment == null ? '' : '/$tokenSegment'}$path'
    '${query.isEmpty ? '' : '?$query'}',
  );
}
