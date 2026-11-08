# Session state

Last updated: 2026-11-07.

## Current work
Branch `feat/windows-desktop`, made from `fix/player-stability-tablet-zoom` after committing its
pending work there (`63a1849`, not pushed). Windows desktop version of the ST app, teachers first.
Nothing on this branch is committed or pushed yet. See CHANGELOG.md.

## Verified
- `flutter pub get`: the three media_kit packages and their small dependencies are additions only; no
  existing package version changed.
- `flutter test`: 220 tests pass (214 before + 6 desktop layout tests).
- `flutter analyze`: no errors; no new warnings in the changed files.
- `flutter build windows --debug`: builds. The first build downloads the Firebase C++ SDK (~960 MB)
  into `build/windows/x64` once (`firebase_core` needs it to compile; it is cached afterwards).
- Ran on Windows (`flutter run -d windows`): starts, reaches the backend, guest home renders with the
  side rail; images load after the bundled-roots fix (before it: CERTIFICATE_VERIFY_FAILED).
- `flutter build apk --debug`: builds, after compiling `device_safety_info` against SDK 36 in
  `android/build.gradle.kts` (its 1.5.4 asks for SDK 37, which AGP 8.11 cannot use; this came with
  the dependency refresh in `63a1849`, so that branch's APK build fails without it).

## Not verified
- Teacher login and video playback on Windows (needs a teacher account on the PC). The player path
  is wired and compiles; playback through media_kit + the proxy has not been watched yet.
- Upload video (TUS), file picker and other teacher forms on Windows.
- Release build, installer (MSIX/Inno Setup) and code signing.

## Open items (Windows)
- Backend/admin: add a `windows` platform to app-update policies; until then Windows skips the check.
- Student version on Windows (later): screen-capture block (`SetWindowDisplayAffinity`), refusing VMs
  and remote desktop, gateway + device key for playback, downloads.
- Firebase C++ SDK makes the first Windows build slow and big; consider dropping `firebase_core` from
  Windows builds if nothing needs it there.
- Refresh `assets/certs/mozilla_roots.pem` from https://curl.se/ca/cacert.pem now and then.
- Pre-existing (seen on Windows hot restart): `search_page.dart` reads a bloc in `dispose()`
  ("Looking up a deactivated widget's ancestor is unsafe").

## Earlier branch (`fix/player-stability-tablet-zoom`)
- Not merged or pushed. Not run on a real device yet: studied marks, tablet gate, player crash fix,
  iPhone zoom. Crashlytics needs enabling in the Firebase console; iOS dSYM upload phase not added.
- Seek points not showing in the admin app: needs a live look (token).
- Backend `main` (incl. migrations) needs a manual deploy.
