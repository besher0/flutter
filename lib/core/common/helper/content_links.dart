import 'package:flutter/services.dart';

import 'show_message.dart';

/// The app links of the shareable pages. They open the same page in the app
/// (see `app_links_navigations.dart`): students share them, teachers copy them.
abstract final class ContentLinks {
  static const _base = 'https://coursay.duckdns.org';

  static String course(String courseId) => '$_base/course?cid=$courseId';

  static String lecture({
    required String lectureId,
    required String lectureName,
    required String courseId,
    bool isCourseFree = false,
  }) =>
      '$_base/lecture?lid=$lectureId'
      '&name=${Uri.encodeComponent(lectureName)}'
      '&cid=$courseId${isCourseFree ? '&fc=_de24s2l' : ''}';

  static String teacher({required String teacherId, required String name}) =>
      '$_base/teacher?tid=$teacherId&name=${Uri.encodeComponent(name)}';

  /// Puts [link] on the clipboard and confirms it.
  static Future<void> copy(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    showMessage('تم نسخ الرابط بنجاح', hasError: false);
  }
}
