# Changelog

Notable changes to the Coursaty student & teacher (ST) app. Newest first.

## 2026-11-03 — branch `fix/player-stability-tablet-zoom`

### Fixed
- **Real tablets refused as emulators.** A single circumstantial signal (no accelerometer, or an
  Intel x86 CPU) showed «يرجى تشغيل التطبيق على جهاز حقيقي». Android now needs one definite emulator
  trace, or two different circumstantial signals, to refuse a device.
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
