import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';

import '../common/constant/configuration/prefs_key.dart';

class PrefsRepositoryImpl extends PrefsRepository {
  PrefsRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? get token => _preferences.getString(PrefsKey.token);

  @override
  Future<bool> setToken(String token) =>
      _preferences.setString(PrefsKey.token, token);

  @override
  Future<bool> clearUser() async {
    const installationDeviceIdKey = 'coursaty_installation_device_id_v2';
    final installationDeviceId = _preferences.getString(
      installationDeviceIdKey,
    );
    final cleared = await _preferences.clear();
    if (installationDeviceId == null) return cleared;
    final restored = await _preferences.setString(
      installationDeviceIdKey,
      installationDeviceId,
    );
    return cleared && restored;
  }

  @override
  Future<bool> removeToken() => _preferences.remove(PrefsKey.token);

  @override
  String? get phone => _preferences.getString(PrefsKey.phone);

  @override
  Future<bool> setPhone(String phone) =>
      _preferences.setString(PrefsKey.phone, phone);

  @override
  List<String>? get roles => _preferences.getStringList(PrefsKey.role);

  @override
  Future<bool> addRole(String role) => _preferences.setStringList(
    PrefsKey.role,
    [role, ..._preferences.getStringList(PrefsKey.role) ?? []],
  );

  @override
  Future<bool> setUserId(String userId) =>
      _preferences.setString(PrefsKey.userId, userId);

  @override
  String? get userId => _preferences.getString(PrefsKey.userId);

  @override
  String? get nhostRefreshToken =>
      _preferences.getString(PrefsKey.refreshToken);

  @override
  Future<void> removeRefreshToken() =>
      _preferences.remove(PrefsKey.refreshToken);

  @override
  Future<void> setRefreshToken(String token) {
    return _preferences.setString(PrefsKey.refreshToken, token);
  }

  @override
  String get languageCode =>
      _preferences.getString(PrefsKey.lang) ??
      PlatformDispatcher.instance.locale.languageCode;

  @override
  Future<bool> setLanguageCode(String code) =>
      _preferences.setString(PrefsKey.lang, code);

  @override
  Future<bool> removeAuthData() => _preferences.remove(PrefsKey.authData);

  @override
  bool getNotificationTopicSubscriptionStatue(String topicKey) =>
      _preferences.getBool(topicKey) ?? true;

  @override
  Future<bool> setNotificationTopicSubscriptionStatue(
    String topicKey,
    bool enabled,
  ) => _preferences.setBool(topicKey, enabled);

  @override
  Future<bool> setOnBoardingSeen(bool seen) =>
      _preferences.setBool(PrefsKey.onBoardingSeen, seen);

  @override
  bool? get onBoardingSeen => _preferences.getBool(PrefsKey.onBoardingSeen);

  @override
  String? get realTime => _preferences.getString(PrefsKey.realTime);

  @override
  Future<bool> setRealTime(DateTime time) =>
      _preferences.setString(PrefsKey.realTime, time.toIso8601String());

  @override
  int? get getAppVersion => _preferences.getInt(PrefsKey.appVersion);

  @override
  Future<bool> setAppVersion(int version) =>
      _preferences.setInt(PrefsKey.appVersion, version);

  @override
  bool get isGuest => _preferences.getBool(PrefsKey.isGuest) ?? false;

  @override
  Future<bool> setIsGuest(bool isGuest) =>
      _preferences.setBool(PrefsKey.isGuest, isGuest);

  @override
  bool? get isSimulator => _preferences.getBool(PrefsKey.isSimulator);

  @override
  Future<bool> setIsSimulator(bool isSimulator) =>
      _preferences.setBool(PrefsKey.isSimulator, isSimulator);

  @override
  bool get isStudent =>
      isGuest || _preferences.getString(PrefsKey.userType) == "STUDENT";

  @override
  bool get isTeacher =>
      !isGuest && _preferences.getString(PrefsKey.userType) == "TEACHER";

  @override
  Future<bool> setUserType(String userType) =>
      _preferences.setString(PrefsKey.userType, userType);

  @override
  String? get name => _preferences.getString(PrefsKey.name);

  @override
  Future<bool> setName(String name) =>
      _preferences.setString(PrefsKey.name, name);

  @override
  Future<bool> setYearCollegeId(String id) =>
      _preferences.setString(PrefsKey.collegeYearId, id);

  @override
  String? get yearCollegeId => _preferences.getString(PrefsKey.collegeYearId);

  @override
  String? get gender => _preferences.getString(PrefsKey.gender);

  @override
  Future<bool> setGender(String gender) =>
      _preferences.setString(PrefsKey.gender, gender);

  @override
  Future<bool> setUniversityNumber(String universityNumber) =>
      _preferences.setString(PrefsKey.universityNumber, universityNumber);

  @override
  String? get universityNumber =>
      _preferences.getString(PrefsKey.universityNumber);

  @override
  bool? get isLightTheme => _preferences.getBool(PrefsKey.theme);

  @override
  Future<bool> setIsLightTheme(bool isLightTheme) =>
      _preferences.setBool(PrefsKey.theme, isLightTheme);

  @override
  String? get collegeId => _preferences.getString(PrefsKey.collegeId);

  @override
  String? get departmentId => _preferences.getString(PrefsKey.departmentId);

  @override
  Future<bool> setCollegeId(String id) {
    return _preferences.setString(PrefsKey.collegeId, id);
  }

  @override
  Future<bool> setDepartmentId(String id) {
    return _preferences.setString(PrefsKey.departmentId, id);
  }

  @override
  Future<bool> setUniversityId(String id) {
    return _preferences.setString(PrefsKey.universityId, id);
  }

  @override
  String? get universityId => _preferences.getString(PrefsKey.universityId);

  @override
  Future<bool> removeDepartmentId() =>
      _preferences.remove(PrefsKey.departmentId);

  @override
  Future<bool> setQuality(String videoUrl, String quality) =>
      _preferences.setString(videoUrl, quality);

  @override
  String? getQuality(String videoUrl) => _preferences.getString(videoUrl);

  @override
  Future<bool> removeQuality(String videoUrl) => _preferences.remove(videoUrl);
}
