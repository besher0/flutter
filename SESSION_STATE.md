# Session state

Last updated: 2026-11-03.

## Current work
Branch `fix/player-stability-tablet-zoom` (from `main` at `684631c`). Not merged or pushed yet.
See CHANGELOG.md for what it contains.

## Verified
- On Flutter 3.47.9: `flutter pub get` resolves with no lock changes besides the new
  `firebase_crashlytics` (and `firebase_core` 4.15.0 → 4.15.2).
- `flutter test`: 190 tests pass.
- `flutter analyze` on the changed files: no errors or warnings (pre-existing infos only).
- `flutter build apk --debug`: builds (Gradle 8.14.3, AGP 8.11.1, Crashlytics plugin + NDK).

## Not verified
- Nothing has been run on a real device. Needs checking on:
  - the studied mark in downloads (card, video page, lecture badge) and its animation;
  - the tablet that showed the "real device" page;
  - a phone that closed suddenly on the player (long 1080p video, drag the progress bar);
  - an iPhone/iPad for zoom (platform-view transform) and the zoom button below the cupertino top bar.
- The iOS app was not built (Windows machine).
- The crash cause is inferred from the code (unbounded buffer, seek storms); Crashlytics will
  confirm or correct it once a release build is in users' hands.
- No release build was made (it would upload the R8 mapping file to Firebase).

## Environment
The dev machine's Flutter SDK was upgraded to 3.47.9 (it was 3.41.9 and could not resolve
`pubspec.lock`). Android needed Gradle 8.14.3 and AGP 8.11.1 for that SDK. One Windows-desktop
engine artifact failed to download (antivirus lock); it only matters for Windows desktop builds.

## Open items
- Crashlytics: enable it in the Firebase console (project of `firebase_options.dart`) if not yet
  done; reports appear after the first crash of a release build. iOS needs the dSYM upload run-script
  phase added in Xcode (on a Mac) for readable native stack traces.
- Seek points not showing in the admin app: code path checks out; needs a live look (token).
- Backend `main` (incl. migrations) needs a manual deploy.
