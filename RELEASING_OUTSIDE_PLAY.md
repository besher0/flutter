# Sharing APKs outside Google Play

Students can sign in from one device only, and the app identifies the device by
Android's `ANDROID_ID`. Since Android 8 that id is different for every signing
key, so the same phone is a *different device* for:

| Build | Signed with |
| --- | --- |
| Installed from Google Play | Google's app signing key |
| `flutter build apk --release` (e.g. `coursaty v2.0.0.apk`) | your upload key (`android/key.properties`) |
| Debug builds | the debug key of the developer's PC |

A student who moves between these builds is locked out ("registered on another
device"). Android also refuses to install one over the other, so a switch means
uninstalling and losing downloaded videos.

**Rule: every APK given to students outside Play is the "Signed, universal APK"
downloaded from Play Console.** It carries Google's key, so it behaves exactly
like the Play version (same device id, and updates install over each other).

## One-time setup

Copy the SHA-256 of the **App signing key certificate** from
Play Console → *Test and release* → *App integrity* → *App signing* into
[`tool/play_app_signing_sha256.txt`](tool/play_app_signing_sha256.txt).

## For every release

1. Build and upload the bundle as usual:
   `flutter build appbundle --release`, then upload it to a Play track.
2. In Play Console open *Test and release* → *Latest releases and bundles*
   (formerly *App bundle explorer*), choose that version, open the
   **Downloads** tab and download **Signed, universal APK**.
3. Check it before sharing:

   ```
   powershell -ExecutionPolicy Bypass -File tool\verify_apk_signing.ps1 "path\to\universal.apk"
   ```

   Share it only when the script prints `OK`. It refuses locally built APKs.

## Never give students

- APKs from `flutter build apk` or Android Studio.
- Debug builds.
- *Internal app sharing* links: Play signs those with a separate internal
  sharing key.

## Testers

Install test builds from a Play **internal testing** track, which uses the same
key as production. A tester whose account was bound by a debug build can be
freed with `POST /v2/admins/students/:studentId/reset-login-device`.

## Students who already have the locally built APK

`coursaty v2.0.0.apk` is signed with the upload key. Those students must
uninstall it and install the Play version (or the universal APK). Do this with
the release that turns on single-device login, so their accounts are bound to
the Play key's device id from the start.
