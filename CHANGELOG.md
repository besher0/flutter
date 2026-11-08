# Changelog

Notable changes to the Coursaty student & teacher (ST) app. Newest first.

## 2026-11-07 — branch `feat/windows-desktop` (from `fix/player-stability-tablet-zoom`)

### Added
- **Windows desktop version (teachers first).** `windows/` runner (window 1280×800, minimum
  1024×680, Arabic title). Same code as the phones; platform checks in `core/platform/app_platform.dart`.
- **Desktop video player:** `media_kit` + `media_kit_video` + `media_kit_libs_windows_video` (libmpv,
  Windows only), behind the same `MyVideoWidgetBetterPlayer` (`app/widgets/desktop_video_player.dart`).
  Same session, loopback proxy, renewal and seek points as the phones; desktop controls (hover,
  keyboard, full screen) plus a speed menu. The phones keep better_player unchanged.
- **Desktop layout:** 1:1 scale (the phone design at real size), content centred within 1280 px,
  home tabs in a side rail, video page as two columns, teacher home metrics in one row, course rows as
  wrapping grids (`AdaptiveCardRow`), forms limited to 760 px (`DesktopFormWidth`), mouse drag scrolls
  horizontal lists (`AppScrollBehavior`).
- **Bundled root certificates on Windows** (`assets/certs/mozilla_roots.pem`, `core/platform/desktop_tls.dart`):
  Dart on Windows only trusts roots already in the Windows store, and a fresh PC often lacks the Bunny
  CDN's root ("SSL.com TLS RSA Root CA 2022"), so every image and video segment failed.

### Changed
- Startup on Windows skips Firebase (push, Crashlytics), hardware crypto, the emulator gate and the
  app-update check (the server has Android/iOS policies only); messages show as a SnackBar (the toast
  plugin has no Windows version).
- Fixed in passing: `HydratedBloc.storage` was set inside the Firebase `try`, so a Firebase failure
  left the saved blocs without storage.
- The splash logo has a fixed width on desktop (the very large image filled the window).

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
