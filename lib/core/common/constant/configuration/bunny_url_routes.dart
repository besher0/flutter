extension ScopeApi on String {
  String get libraryScope => 'library/$this';

  String get uploadsScope => 'uploads/$this';
}

abstract class BunnyEndPoints {
  static String getResolutions({
    required String libraryId,
    required String videoId,
  }) {
    return '${''.libraryScope}$libraryId/videos/$videoId/play';
  }

  static String uploadFile = 'files'.uploadsScope;
  static String uploadVideoTusEP = 'tusupload';
}

class BunnyUrlRoutes {
  static String get baseUrl => _baseUrlDev;

  static String get baseUrlWithHttp => _baseUrlDevWithHttp;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = 'https://video.bunnycdn.com/';
  static const String _baseUrlDevWithHttp = 'https://video.bunnycdn.com/';
}
