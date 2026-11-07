import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/prefs_repository.dart';

/// Which videos the student marked as studied, kept on this device only.
///
/// One store for online and downloaded courses: a video studied online shows
/// as studied in the downloads and the other way round. Marks are kept per
/// account (another account on the same phone starts empty), and stay when a
/// download is deleted.
///
/// A lecture is studied once all of its videos are, including videos that
/// were never downloaded. Each lecture's full video list is remembered from
/// the server's lecture details whenever the lecture is opened online
/// ([rememberLectureVideos]), so the downloads, which only show what is on
/// the device, still know the real total.
class StudyProgressStore extends ChangeNotifier {
  StudyProgressStore({
    required SharedPreferences prefs,
    required String? Function() accountId,
  }) : _prefs = prefs,
       _accountId = accountId;

  static StudyProgressStore? _instance;

  static StudyProgressStore get instance => _instance ??= StudyProgressStore(
    prefs: GetIt.I<SharedPreferences>(),
    accountId: () => GetIt.I<PrefsRepository>().userId,
  );

  @visibleForTesting
  static set instanceForTesting(StudyProgressStore? store) => _instance = store;

  static const _keyPrefix = 'coursaty_study_progress_v1_';

  final SharedPreferences _prefs;
  final String? Function() _accountId;

  String? _loadedFor;
  Set<String> _studied = {};
  Map<String, List<String>> _lectureVideos = {};

  bool isVideoStudied(String videoId) {
    _ensureLoaded();
    return _studied.contains(videoId);
  }

  void setVideoStudied(String videoId, bool studied) {
    _ensureLoaded();
    final changed = studied ? _studied.add(videoId) : _studied.remove(videoId);
    if (!changed) return;
    _save();
    notifyListeners();
  }

  /// Records [lectureId]'s complete list of video ids. Lists from the server
  /// overwrite; a saved download's copy ([overwrite] false) is only used when
  /// nothing better is known, since older downloads may list fewer videos.
  void rememberLectureVideos(
    String lectureId,
    Iterable<String> videoIds, {
    bool overwrite = true,
  }) {
    _ensureLoaded();
    final ids = videoIds.toList();
    final known = _lectureVideos[lectureId];
    if (known != null && (!overwrite || listEquals(known, ids))) return;
    _lectureVideos[lectureId] = ids;
    _save();
    notifyListeners();
  }

  int totalVideoCountOf(String lectureId) {
    _ensureLoaded();
    return _lectureVideos[lectureId]?.length ?? 0;
  }

  int studiedVideoCountOf(String lectureId) {
    _ensureLoaded();
    return (_lectureVideos[lectureId] ?? const <String>[])
        .where(_studied.contains)
        .length;
  }

  /// All of the lecture's videos are studied (a lecture with no known video,
  /// or none at all, is not).
  bool isLectureStudied(String lectureId) {
    final total = totalVideoCountOf(lectureId);
    return total > 0 && studiedVideoCountOf(lectureId) >= total;
  }

  String get _account {
    final id = _accountId();
    return id == null || id.isEmpty ? 'guest' : id;
  }

  /// Loads the signed-in account's marks; switching account switches marks.
  void _ensureLoaded() {
    final account = _account;
    if (_loadedFor == account) return;
    _loadedFor = account;
    _studied = {};
    _lectureVideos = {};
    final raw = _prefs.getString('$_keyPrefix$account');
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _studied = {for (final id in json['videos'] as List? ?? const []) '$id'};
      final lectures = json['lectures'] as Map<String, dynamic>? ?? const {};
      _lectureVideos = {
        for (final entry in lectures.entries)
          entry.key: [for (final id in entry.value as List) '$id'],
      };
    } catch (error) {
      debugPrint('study progress unreadable: ${error.runtimeType}');
    }
  }

  void _save() {
    final account = _loadedFor;
    if (account == null) return;
    final raw = jsonEncode({
      'videos': _studied.toList(),
      'lectures': _lectureVideos,
    });
    _prefs.setString('$_keyPrefix$account', raw).catchError((Object error) {
      debugPrint('study progress not saved: ${error.runtimeType}');
      return false;
    });
  }
}
