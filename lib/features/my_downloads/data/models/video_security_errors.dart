import 'dart:io';

import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:dio/dio.dart';

/// Stable `errorCode` values returned by the backend video security flows.
///
/// The backend's exception filter copies the code into `errorCode`; older
/// deployments put it in `message` instead, so both are checked.
abstract final class VideoErrorCodes {
  static const deviceLimitReplacementRequired =
      'VIDEO_DEVICE_LIMIT_EXCEEDED_REPLACEMENT_REQUIRED';
  static const deviceKeyMismatchReplacementRequired =
      'VIDEO_DEVICE_KEY_MISMATCH_REPLACEMENT_REQUIRED';
  static const deviceKeyInvalid = 'VIDEO_DEVICE_KEY_INVALID';
  static const deviceKeyNotRegistered = 'VIDEO_DEVICE_KEY_NOT_REGISTERED';
  static const deviceSignatureRequired = 'VIDEO_DEVICE_SIGNATURE_REQUIRED';
  static const deviceSignatureInvalid = 'VIDEO_DEVICE_SIGNATURE_INVALID';
  static const deviceConcurrentUpdate = 'VIDEO_DEVICE_CONCURRENT_UPDATE';
  static const challengeRequired = 'VIDEO_PLAYBACK_CHALLENGE_REQUIRED';
  static const challengeInvalid = 'VIDEO_PLAYBACK_CHALLENGE_INVALID';
  static const playIntegrityFailed = 'VIDEO_PLAY_INTEGRITY_FAILED';
  static const playbackSessionInvalid = 'VIDEO_PLAYBACK_SESSION_INVALID';
  static const rateLimited = 'VIDEO_RATE_LIMITED';
  static const studentRequired = 'VIDEO_STUDENT_REQUIRED';
  static const teacherNotOwner = 'VIDEO_TEACHER_NOT_OWNER';
  static const accountInactive = 'VIDEO_ACCOUNT_INACTIVE';
  static const subscriptionRequired = 'VIDEO_SUBSCRIPTION_REQUIRED';
  static const subscriptionExpired = 'VIDEO_SUBSCRIPTION_EXPIRED';
  static const courseExpired = 'VIDEO_COURSE_EXPIRED';
  static const downloadDisabled = 'VIDEO_DOWNLOAD_DISABLED';
  static const guestFreeOnly = 'VIDEO_GUEST_FREE_ONLY';
  static const bunnyIdMissing = 'VIDEO_BUNNY_ID_MISSING';

  static const _all = {
    deviceLimitReplacementRequired,
    deviceKeyMismatchReplacementRequired,
    deviceKeyInvalid,
    deviceKeyNotRegistered,
    deviceSignatureRequired,
    deviceSignatureInvalid,
    deviceConcurrentUpdate,
    challengeRequired,
    challengeInvalid,
    playIntegrityFailed,
    playbackSessionInvalid,
    rateLimited,
    studentRequired,
    teacherNotOwner,
    accountInactive,
    subscriptionRequired,
    subscriptionExpired,
    courseExpired,
    downloadDisabled,
    guestFreeOnly,
    bunnyIdMissing,
  };
}

/// Returns the backend video error code carried by [error], if any.
String? videoErrorCodeOf(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is! Map) return null;
  for (final key in const ['errorCode', 'code', 'message']) {
    final value = data[key];
    if (value is String && VideoErrorCodes._all.contains(value)) return value;
  }
  return null;
}

/// The device cannot use the hardware-backed video key flow (for example iOS,
/// where the native Secure Enclave bridge is not implemented yet).
class VideoDeviceSecurityUnsupportedException implements Exception {
  const VideoDeviceSecurityUnsupportedException();

  @override
  String toString() => 'Video device security is not supported on this device';
}

/// Why a protected download stopped, for errors that do not come from the
/// backend API itself.
enum SecureDownloadFailure {
  /// The backend did not return a gateway session (accessToken), e.g. an old
  /// deployment that still hands out direct CDN links. Never fall back.
  gatewaySessionMissing,

  /// A playlist pointed outside the gateway origin. The session header must
  /// never be sent to another host, so the download stops.
  untrustedMediaHost,

  /// The gateway refused the session (401/403) even after a fresh session.
  gatewayAccessDenied,

  /// The gateway returned something that is not a usable HLS playlist.
  invalidPlaylist,

  /// The offline license from the backend failed local verification.
  offlineLicenseInvalid,

  /// Rooted device or emulator.
  insecureDevice,
}

class SecureDownloadException implements Exception {
  const SecureDownloadException(this.failure, [this.detail]);

  final SecureDownloadFailure failure;

  /// Developer detail for logs. Never contains tokens or signed URLs.
  final String? detail;

  @override
  String toString() =>
      'SecureDownloadException(${failure.name}${detail == null ? '' : ': $detail'})';
}

/// Warning shown when this installation is not the account's video device.
/// Device replacement is suspended ([videoDeviceReplacementEnabled]), so the
/// message only explains the problem and offers no action.
String videoDeviceConflictMessage(
  DeviceReplacementReason reason, {
  bool download = false,
}) {
  final action = download ? 'تحميل' : 'تشغيل';
  switch (reason) {
    case DeviceReplacementReason.deviceLimit:
      return 'هذا الحساب مرتبط بجهاز آخر، لذا لا يمكن $action الفيديوهات '
          'على هذا الجهاز. إذا غيّرت جهازك تواصل مع الدعم.';
    case DeviceReplacementReason.keyMismatch:
      return 'تعذر التحقق من مفتاح الأمان لهذا الجهاز (قد يحدث بعد إعادة '
          'تثبيت التطبيق أو مسح بياناته)، لذا لا يمكن $action الفيديوهات '
          'عليه. تواصل مع الدعم.';
  }
}

const _unsupportedDeviceMessage =
    'تشغيل الفيديوهات المحمية غير مدعوم على هذا الجهاز حالياً';

/// User-facing (Arabic) message for a playback failure.
String videoPlaybackErrorMessage(Object error, {required bool isTeacher}) {
  if (error is VideoDeviceSecurityUnsupportedException) {
    return _unsupportedDeviceMessage;
  }
  final conflict = DeviceReplacementRequiredException.fromError(error);
  if (conflict != null) return videoDeviceConflictMessage(conflict.reason);
  switch (videoErrorCodeOf(error)) {
    case VideoErrorCodes.subscriptionRequired:
      return 'هذا الفيديو غير مجاني. اشترك في الكورس لمشاهدته';
    case VideoErrorCodes.guestFreeOnly:
      return 'هذا الفيديو غير مجاني. سجّل الدخول أو اشترك لمشاهدته';
    case VideoErrorCodes.subscriptionExpired:
      return 'انتهت صلاحية اشتراكك في هذا الكورس';
    case VideoErrorCodes.courseExpired:
      return 'انتهت صلاحية هذا الكورس';
    case VideoErrorCodes.teacherNotOwner:
      return 'لا تملك صلاحية تشغيل فيديو هذا الكورس';
    case VideoErrorCodes.accountInactive:
      return 'الحساب غير فعال. تواصل مع الدعم';
    case VideoErrorCodes.deviceKeyInvalid:
    case VideoErrorCodes.deviceKeyNotRegistered:
    case VideoErrorCodes.deviceSignatureRequired:
    case VideoErrorCodes.deviceSignatureInvalid:
    case VideoErrorCodes.challengeRequired:
    case VideoErrorCodes.challengeInvalid:
    case VideoErrorCodes.playIntegrityFailed:
      return 'تعذر التحقق من أمان هذا الجهاز. أعد المحاولة أو تواصل مع الدعم';
    case VideoErrorCodes.deviceConcurrentUpdate:
      return 'يجري تحديث أجهزة حسابك حالياً، أعد المحاولة بعد قليل';
    case VideoErrorCodes.rateLimited:
      return 'محاولات كثيرة، انتظر قليلاً ثم أعد المحاولة';
    case VideoErrorCodes.bunnyIdMissing:
      return 'هذا الفيديو غير متاح حالياً';
    case VideoErrorCodes.downloadDisabled:
      return 'التحميل غير متاح لهذا الفيديو';
    case VideoErrorCodes.studentRequired:
      return 'هذه الميزة متاحة لحسابات الطلاب فقط';
  }
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == null) return 'تحقق من اتصالك بالإنترنت ثم أعد المحاولة';
    switch (status) {
      case 401:
        return 'انتهت الجلسة، سجّل الدخول مجدداً';
      case 403:
        return isTeacher
            ? 'لا تملك صلاحية تشغيل فيديو هذا الكورس'
            : 'هذا الفيديو غير مجاني. سجّل الدخول أو اشترك لمشاهدته';
      case 404:
        return 'الفيديو غير موجود أو غير متاح';
      case 429:
        return 'محاولات كثيرة، انتظر قليلاً ثم أعد المحاولة';
      case 502:
      case 503:
      case 504:
        return 'الفيديو قيد المعالجة أو الخدمة غير متاحة مؤقتاً';
      case 400:
        return 'تعذر تشغيل الفيديو حالياً';
    }
  }
  if (error is SocketException) {
    return 'تحقق من اتصالك بالإنترنت ثم أعد المحاولة';
  }
  return 'تعذر تشغيل الفيديو';
}

/// User-facing (Arabic) message for a failed offline download.
String videoDownloadErrorMessage(Object error) {
  if (error is VideoDeviceSecurityUnsupportedException) {
    return 'تحميل الفيديوهات المحمية غير مدعوم على هذا الجهاز حالياً';
  }
  if (error is FileSystemException && _isOutOfSpace(error)) {
    return 'لا توجد مساحة تخزين كافية لتحميل الفيديو';
  }
  if (error is SecureDownloadException) {
    switch (error.failure) {
      case SecureDownloadFailure.gatewaySessionMissing:
      case SecureDownloadFailure.untrustedMediaHost:
        return 'التحميل الآمن غير متاح حالياً. أعد المحاولة لاحقاً';
      case SecureDownloadFailure.gatewayAccessDenied:
        return 'انتهت صلاحية جلسة التحميل أو رُفضت. أعد المحاولة لاستكمال التحميل';
      case SecureDownloadFailure.invalidPlaylist:
        return 'ملف الفيديو غير جاهز للتحميل حالياً. أعد المحاولة لاحقاً';
      case SecureDownloadFailure.offlineLicenseInvalid:
        return 'تعذر التحقق من رخصة التحميل. أعد المحاولة';
      case SecureDownloadFailure.insecureDevice:
        return 'لا يمكن تنزيل الفيديو على جهاز غير آمن';
    }
  }
  final conflict = DeviceReplacementRequiredException.fromError(error);
  if (conflict != null) {
    return videoDeviceConflictMessage(conflict.reason, download: true);
  }
  if (error is VideoDeviceRegistrationException) {
    return 'تعذر تسجيل هذا الجهاز لتحميل الفيديوهات. أعد تشغيل التطبيق ثم حاول مجدداً';
  }
  final code = videoErrorCodeOf(error);
  if (code != null) return videoPlaybackErrorMessage(error, isTeacher: false);
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال أثناء التحميل. أعد المحاولة لاستكمال التحميل';
      default:
        break;
    }
    switch (error.response?.statusCode) {
      case null:
        return 'انقطع الاتصال أثناء التحميل. أعد المحاولة لاستكمال التحميل';
      case 401:
        return 'انتهت الجلسة، سجّل الدخول مجدداً';
      case 403:
        return 'لا تملك صلاحية تحميل هذا الفيديو';
      case 429:
        return 'محاولات كثيرة، انتظر قليلاً ثم أعد المحاولة';
      case 502:
      case 503:
      case 504:
        return 'الفيديو قيد المعالجة أو الخدمة غير متاحة مؤقتاً';
    }
  }
  if (error is SocketException) {
    return 'انقطع الاتصال أثناء التحميل. أعد المحاولة لاستكمال التحميل';
  }
  return 'حدثت مشكلة أثناء التحميل';
}

bool _isOutOfSpace(FileSystemException error) {
  final osError = error.osError;
  if (osError == null) return false;
  // ENOSPC on Linux/Android (28), iOS/macOS (28); ERROR_DISK_FULL (112) on Windows.
  return osError.errorCode == 28 ||
      osError.errorCode == 112 ||
      osError.message.toLowerCase().contains('no space');
}
