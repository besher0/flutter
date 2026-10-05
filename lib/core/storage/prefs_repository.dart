abstract class PrefsRepository {
  String? get nhostRefreshToken;

  String? get token;

  String? get name;

  String? get gender;

  String? get phone;

  String? get userId;

  List<String>? get roles;

  String get languageCode;

  bool getNotificationTopicSubscriptionStatue(String topicKey);

  String? get realTime;

  String? get yearCollegeId;

  String? get collegeId;

  String? get universityId;

  String? get departmentId;

  String? get universityNumber;

  int? get getAppVersion;

  bool get isStudent;

  bool get isGuest;

  bool? get isSimulator;

  bool? get isLightTheme;

  bool? get onBoardingSeen;

  Future<bool> setIsGuest(bool isGuest);

  Future<bool> setIsSimulator(bool isSimulator);

  Future<bool> setIsLightTheme(bool isLightTheme);

  Future<bool> setRealTime(DateTime time);

  Future<bool> setAppVersion(int version);

  Future<void> setRefreshToken(String token);

  Future<bool> setToken(String token);

  Future<bool> setUniversityNumber(String universityNumber);

  Future<bool> setGender(String gender);

  Future<bool> setName(String name);

  Future<bool> setPhone(String phone);

  Future<bool> setUserId(String userId);

  Future<bool> addRole(String role);

  Future<bool> setLanguageCode(String code);

  Future<bool> setNotificationTopicSubscriptionStatue(
    String topicKey,
    bool enabled,
  );

  Future<bool> setOnBoardingSeen(bool seen);

  Future<bool> setUserType(String userType);

  Future<bool> setYearCollegeId(String id);

  Future<bool> setDepartmentId(String id);

  Future<bool> setCollegeId(String id);

  Future<bool> setUniversityId(String id);

  String? getQuality(String videoUrl);

  Future<bool> setQuality(String videoUrl, String quality);

  Future<bool> clearUser();

  Future<bool> removeQuality(String videoUrl);
  Future<bool> removeToken();

  Future<bool> removeAuthData();

  Future<void> removeRefreshToken();

  Future<bool> removeDepartmentId();
}
