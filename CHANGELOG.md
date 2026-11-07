# Changelog

Notable changes to the Coursaty student & teacher (ST) app. Newest first.

## 2026-11-03 — branch `fix/player-stability-tablet-zoom`

### Added
- **Studied videos (online and downloads).** A video can be marked as studied from its card and
  from the video page (top bar), in online courses and in downloads. The mark is a wavy-edged seal
  that springs in, fills amber, draws a check and bursts sparkles. A lecture shows «مدروسة» (lecture
  lists and lecture page) only once **all** its videos are studied, downloaded or not; until then the
  lecture page shows «درست X من Y فيديو». Stored locally per account (`StudyProgressStore`), shared by
  online and downloads, and kept when a download is deleted.
- **iOS universal links.** Added the missing Associated Domains entitlement and the server's
  `apple-app-site-association`; removed an invalid `https` custom URL scheme from `Info.plist`.
- Fixed: the downloaded lecture page filtered the saved lecture's own file/video lists in place, so
  the downloads state lost the videos that were not downloaded.
- Course page links (Telegram channel, Instagram page, teacher's group) are now a plain icon + label
  (`CourseLinkTile`) instead of coloured buttons with an arrow, with a new vector Telegram logo
  (`assets/icons/telegram_logo.svg`).
- Fixed in passing: a downloaded video card could show another video's name when some of the
  lecture's videos were not downloaded.
- **Crash reporting** with Firebase Crashlytics: native crashes (incl. Android NDK), uncaught Dart
  errors, and player breadcrumbs/handled errors. Off in debug builds; only the role is attached.

### Build
- Flutter SDK 3.47.9 (matches `pubspec.lock`); Gradle wrapper 8.12 → 8.14.3; Android Gradle Plugin
  8.9.1 → 8.11.1 (required by Flutter 3.47); Crashlytics Gradle plugin 3.0.6.

### Changed
- Course pages (online and downloaded): the teacher's Instagram button and the Telegram group button
  are replaced by «قناة التلجرام» (t.me/coursaty_application), «صفحة الإنستجرام» (Coursaty's page) and
  «غروب المناقشة مع الأستاذ» (the course's `telegramUrl`, same access rules as before).

### Fixed
- **Real devices refused as emulators.** «يرجى تشغيل التطبيق على جهاز حقيقي» now shows only on
  emulators: Android refuses on proof of an emulator (emulator build/files/properties, an x86 VM, or a
  QEMU trace inside one), never on hints real devices share (no accelerometer, Intel CPU, generic
  fingerprint, QEMU leftovers, a failed check). Chromebooks are allowed. The native check now reports
  every emulator file it finds and whether the device is a Chromebook.
- **Heavy seeking.** better_player's progress bar seeked on every drag update (~60/s); seeks are now
  merged (`SmoothSeekBetterPlayerController`): one at a time, at least 300 ms apart, always ending
  at the last position.
- **Sudden closes on the player (probable cause).** ExoPlayer was allowed to buffer ~109 minutes
  (up to ~130 MB of video in Java heap). The buffer is capped at 50 s ahead.
- **UI isolate load.** The online playback proxy runs in its own isolate.

### Changed
- Zoom reset button: smaller (30 px, 40 px tap target) and at the top right.
- Pinch zoom also enabled on iOS, with the cupertino controls drawn above the zoomed picture.

## 2026-10-26
- iPhone paid-content switch also hides teacher earnings and price/free fields (`07d2982`).
- «اشتراكاتي» tab hidden with paid content (`15a6dc5`).

## 2026-10-24
- No black flash on playback-session renewal (loopback proxy); controls usable while zoomed
  (`91db7e9`).
