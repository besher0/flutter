extension ScopeApi on String {
  String get noScope => this;

  String get adminScope => 'admin/$this';

  String get AdminScope => 'Admin/$this';

  String get authScope => 'auth/$this';

  String get usersScope => 'users/$this';

  String get studentsScope => 'students/$this';

  String get teachersScope => 'teachers/$this';

  String get academicsScope => 'academics/$this';

  String get coursesScope => 'courses/$this';

  String get uploadsVideosScope => 'uploads/videos/$this';

  String get dashboardScope => 'dashboard/$this';

  String get interactionsScope => 'interactions/$this';

  String get lecturesScope => 'lectures/$this';
}

abstract class EndPoints {
  ///! ----< user >----
  ///

  static final guestEP = 'guest-preferences';
  static final createLecture = 'lectures';

  static final signUpEP = 'register-complete'.authScope;
  static final loginEp = 'login'.authScope;
  static final createStudentEp = ''.studentsScope;
  static final updateStudentEp = 'me/student'.usersScope;
  static final createTeacherEp = ''.teachersScope;
  static final getTeacherSummaryEp = 'me/summary'.teachersScope;
  static final getAllowedSubjectsEP = 'me/allowed-subjects'.teachersScope;
  static final profileEP = 'me'.usersScope;
  static final changePasswordEP = 'me/change-password'.usersScope;
  static final createCourseEP = '/courses'.noScope;

  static final getUniversitiesEp = 'universities'.academicsScope;
  static final getCollegesEp = 'colleges'.academicsScope;
  static final getDepartmentsEP = 'departments'.academicsScope;
  static final getYearsEp = 'years'.academicsScope;
  static final getAllSeasonsEP = 'seasons'.academicsScope;

  static final getNotificationsEP = 'notifications'.noScope;
  static final getTeacherNotifications = 'notifications/my'.noScope;
  static final addNotificationEP = '/notifications'.noScope;
  static final getSalesPoints = 'point-of-sales'.noScope;
  static final getAdvertisementsEp = 'advertisements'.noScope;

  static final getCoursesCategoriesEP = 'categories'.coursesScope;

  static final search = 'search'.dashboardScope;
  static final getHomeContentEp = 'student-college-info'.dashboardScope;
  static final getTeachersEP = 'college-teachers'.dashboardScope;
  static final getAllProgramsEP = 'programs/courses'.dashboardScope;
  static final getFilteredSubjectsEP = 'student/subjects'.dashboardScope;
  static final getCoursesWithFiltering = 'courses'.dashboardScope;

  static final likeTeacherEp = 'teachers/like'.interactionsScope;
  static final rateEp = 'courses/rate'.interactionsScope;
  static final getLikedTeachersEP = 'liked-teachers'.dashboardScope;
  static final getTeacherAffiliations = 'me/affiliations'.teachersScope;
  static final getTeacherWithdrawals = 'me/withdrawals'.teachersScope;
  static final getTeacherRevenues = 'me/revenue'.teachersScope;

  static final getCustomerServiceEP = 'customer-service'.noScope;
  static final getMyActiveCourses =
      'financials/subscriptions/me/active-courses'.noScope;
  static final getMyInActiveCourses =
      'financials/subscriptions/me/inactive-courses'.noScope;
  static final scanCodeEP = 'financials/subscriptions/subscribe'.noScope;
  static final getCourseInterests = 'students/me/course-interests'.noScope;
  static final createSubscriptionRequestWithReceipt =
      'financials/subscription-requests/with-receipt'.noScope;
  static final createVideo = 'videos'.lecturesScope;
  static final initTusEp = 'tus/init'.uploadsVideosScope;
  static final completeTusEp = 'tus/complete'.uploadsVideosScope;

  static final createVideoLikeEP = 'videos'.interactionsScope;

  static final createFileEP = 'files'.lecturesScope;

  static String updateVideoLikeEP({required String id}) {
    return 'videos/$id'.uploadsVideosScope;
  }

  static String editVideo({required String id}) {
    return 'videos/$id'.lecturesScope;
  }

  static String editFile({required String id}) {
    return 'files/$id'.lecturesScope;
  }

  static String deleteQuestionEP({required String id}) {
    return 'questions/$id'.lecturesScope;
  }

  static String deleteFile(String id) {
    return 'files/$id'.lecturesScope;
  }

  static String deleteVideo(String id) {
    return 'videos/$id'.lecturesScope;
  }

  static String editVideoSegment({
    required String id,
    required String videoId,
  }) {
    return 'videos/$videoId/segments/$id'.lecturesScope;
  }

  static String createQuestionEP({required String lectureId}) {
    return '$lectureId/questions'.lecturesScope;
  }

  static String createVideoSegmentEP({required String videoId}) {
    return 'videos/$videoId/segments'.lecturesScope;
  }

  static String getVideoSegmentsEP({required String videoId}) {
    return 'videos/$videoId/segments'.lecturesScope;
  }

  static String deleteVideoSegmentsEP({
    required String videoId,
    required String id,
  }) {
    return 'videos/$videoId/segments/$id'.lecturesScope;
  }

  static String editQuestion({required String id}) {
    return 'questions/$id'.lecturesScope;
  }

  static String getCourseRating({required String id}) {
    return 'courses/$id/rate'.interactionsScope;
  }

  static String getTeacherCoursesEP({required bool getActive}) {
    return 'me/courses/${getActive ? 'active' : 'expired'}'.teachersScope;
  }

  static String getTeacherDetails({required String id}) {
    return '${'teachers'.dashboardScope}/$id';
  }

  static String getLectureDetails({required String id}) {
    return '${''.lecturesScope}$id/details';
  }

  static String getCourseDetails({required String id}) {
    return '${''.coursesScope}$id/details';
  }

  static String courseInterest(String courseId) {
    return 'students/me/course-interests/$courseId'.noScope;
  }

  static String getVideoResolutions({required String id}) {
    return '${''.uploadsVideosScope}$id/resolutions';
  }

  static String createPlaybackSession({required String videoId}) {
    return 'videos/$videoId/playback-session'.noScope;
  }

  static String get registerVideoDeviceKey => 'devices/video-key'.noScope;

  static String get replaceVideoDeviceKey => 'devices/video-key/replace'.noScope;

  static String createGuestPlaybackSession({required String videoId}) {
    return 'videos/$videoId/guest-playback-session'.noScope;
  }

  static String createPlaybackChallenge({required String videoId}) {
    return 'videos/$videoId/playback-challenge'.noScope;
  }

  static String refreshPlaybackSession({
    required String videoId,
    required String sessionId,
  }) {
    return 'videos/$videoId/playback-session/$sessionId/refresh'.noScope;
  }

  static String createDownloadSession({required String videoId}) {
    return 'videos/$videoId/download-session'.noScope;
  }

  static String renewOfflineLicense({required String videoId}) {
    return 'videos/$videoId/offline-license/renew'.noScope;
  }

  static String getOfflineLicensePublicKey() {
    return 'videos/offline-license/public-key'.noScope;
  }

  static String getCourseStatistics({required String id}) {
    return '${''.coursesScope}$id/statistics';
  }

  static String getVideoLikes({required String id}) {
    return 'videos/$id/likes'.interactionsScope;
  }

  static String getCourseBySubject({required String id}) {
    return '${'subjects'.dashboardScope}/$id/courses';
  }

  static String getCourseByYear({required String id}) {
    return '${'years'.dashboardScope}/$id/courses';
  }
}

abstract class MasterUrlRoutes {
  /// Every backend route lives under /v2. The unversioned paths are retired,
  /// so app builds from before /v2 get an "update the app" answer.
  static const String apiVersionPath = 'v2';

  /// Backend path for an [endpoint] such as `auth/login`.
  static String apiPath(String endpoint) =>
      '/$apiVersionPath/${endpoint.replaceFirst(RegExp(r'^/+'), '')}';

  /// Base URL of the versioned API, for string-built URLs.
  static String get baseUrl => '$_baseUrlDev$apiVersionPath/';

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev =
      'https://coursay.duckdns.org/'; //'http://64.23.251.1/';
  static const String _baseUrlDevWithHttp = 'http://coursay.duckdns.org/';

  static const int? _port = null;

  static int? get port => _port;
}
