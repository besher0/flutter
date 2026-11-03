# Session state

Last updated: 2026-11-03.

## Current work
Branch `fix/player-stability-tablet-zoom` (from `main` at `684631c`). Not merged or pushed yet.
See CHANGELOG.md for what it contains.

## Verified
- `flutter test --no-pub`: 176 tests pass.
- `flutter analyze` on the changed files: no errors or warnings (pre-existing infos only).
- `flutter build apk --debug --no-pub`: builds.

## Not verified
- Nothing has been run on a real device. Needs checking on:
  - the tablet that showed the "real device" page;
  - a phone that closed suddenly on the player (long 1080p video, drag the progress bar);
  - an iPhone/iPad for zoom (platform-view transform) and the zoom button below the cupertino top bar.
- The iOS app was not built (Windows machine).
- The crash cause is inferred from the code (unbounded buffer, seek storms); there is no crash
  report to confirm it.

## Environment note
`main` now requires `pdfrx >=2.4.8`, which needs `meta 1.18`; the Flutter SDK on the dev machine used
here (3.41.9) pins `meta 1.17`, so `flutter pub get` fails there. Tests and the build ran with
`--no-pub` against the previously resolved packages (pdfrx 2.4.7). Use the newer Flutter SDK that
`main` was resolved with.

## Open items
- Add crash reporting (e.g. `firebase_crashlytics`; Firebase is already set up) to confirm the cause
  of sudden closes in the field.
- Seek points not showing in the admin app: code path checks out; needs a live look (token).
- Backend `main` (incl. migrations) needs a manual deploy.
