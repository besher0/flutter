import 'dart:typed_data';

/// Decrypted HLS segments of one offline playback session.
///
/// Each segment is decrypted once (concurrent requests share the work), the
/// most recent few stay in memory, and the next segment is decrypted ahead of
/// the player. Without this a high-bitrate (e.g. 1080p) segment was decrypted
/// only when the player asked for it, and again for every range request,
/// which stalled playback.
class DecryptedSegmentCache {
  DecryptedSegmentCache(this._decrypt, {this.capacity = 3});

  final Future<Uint8List> Function(int index) _decrypt;
  final int capacity;

  /// Insertion order is recency: the last entry is the most recently used.
  final Map<int, Future<Uint8List>> _entries = {};

  Future<Uint8List> get(int index) {
    final future = _entries.remove(index) ?? _start(index);
    _entries[index] = future;
    while (_entries.length > capacity) {
      _entries.remove(_entries.keys.first);
    }
    return future;
  }

  /// Starts decrypting [index] in the background if it is not cached yet.
  void prefetch(int index) {
    if (_entries.containsKey(index)) return;
    get(index).ignore();
  }

  void clear() => _entries.clear();

  Future<Uint8List> _start(int index) {
    final future = _decrypt(index);
    // A failed decryption is not cached, so the next request retries it.
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_entries[index], future)) _entries.remove(index);
      },
    );
    return future;
  }
}
