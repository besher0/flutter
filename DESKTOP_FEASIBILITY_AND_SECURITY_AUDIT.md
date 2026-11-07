# Desktop Feasibility and Security Audit — Coursaty ST app

Date: 2026-11-03. Scope: the student/teacher Flutter app in `flutter/` (branch
`fix/player-stability-tablet-zoom`, based on `main` `684631c`) and the backend rules it depends on in
`coursaty/`. Assessment only: no application code was changed, nothing was installed.

**Business constraints given by the product owner**

- The desktop app plays videos **online only** (no downloads).
- Security criterion **S1**: deny screenshots and screen recording by every means (other apps and the
  OS's own capture tools).
- Security criterion **S2**: links to protected content (above all videos) received by the app must
  work **inside the app only**.

**How to read this report.** Every statement is tagged:
**[V]** verified in this repository or in the resolved package source; **[D]** taken from vendor or
platform documentation or public reports (sources at the end); **[A]** an assumption or estimate.

---

## 1. Executive summary

| Platform | Recommendation | Why |
|---|---|---|
| **Windows** | **CONDITIONAL GO** (build first) | The OS offers a real capture-exclusion API (`SetWindowDisplayAffinity(WDA_EXCLUDEFROMCAPTURE)`, Windows 10 2004+) that hides the window from Snipping Tool, Print Screen, Game Bar, OBS, Teams/Zoom sharing and Recall [D]. S1 is met against software capture on the same machine, **not** against a camera, an HDMI capture card, a virtual display driver, or running the app inside a virtual machine (the last can be detected and refused). S2 is achievable with backend changes (gateway mode, device-bound and IP-bound sessions, certificate pinning). Conditions: the backend work in §8 and a new video player. |
| **macOS** | **CONDITIONAL GO, second, only with FairPlay DRM** | The window-level flag (`NSWindow.sharingType = .none`) is reportedly **not honoured by ScreenCaptureKit on macOS 15+** [D], which is what QuickTime, the screenshot tool and most recorders use now. S1 on modern macOS therefore needs FairPlay-protected playback (protected content renders black in captures [D]), i.e. Bunny MediaCage Enterprise DRM ($99/month + licence fees [D]) and a custom AVPlayer plugin. Also needs a Mac, an Apple Developer account and notarization. |
| **Linux** | **NO-GO** for the stated criteria | Linux compositors (X11/Wayland) expose no API to exclude a window from capture. The app's own `no_screenshot` plugin confirms its Linux "prevention" only logs a message [V]. S1 cannot be met. |

**Is it feasible?** Yes for Windows, with honest limits: no desktop app can stop a phone camera or an
HDMI capture card. Those need deterrence (a visible per-student watermark) and accountability, not
prevention.

**Biggest blockers [V]:** the video player (`better_player_plus`) has no desktop support; the UI is
scaled from a 375-px phone design with ScreenUtil; the login token lives 365 days in plain
SharedPreferences with no server-side logout; video "app-only" mode on the backend relies on Google
Play Integrity, which desktop cannot provide.

**Expected effort [A]:** Windows production-ready ≈ **45 developer-days** (range 32–65); macOS adds
≈ 30 (20–45); Linux not recommended.

---

## 2. Existing architecture assessment

### 2.1 Facts [V]

| Area | Finding | Evidence |
|---|---|---|
| Toolchain | Flutter 3.47.9, Dart 3.13.7; Android: Gradle 8.14.3, AGP 8.11.1 | `flutter --version`, `android/settings.gradle.kts` |
| Platforms enabled | `android/`, `ios/`, `web/` only; **no `windows/`, `macos/`, `linux/`** | repository root |
| Size | 378 Dart files, ~51.5k lines, ~48 screens/pages, 29 test files | `lib/`, `test/` |
| Architecture | Feature folders with `data / domain / presentation`; use cases return `Either<Failure,T>` | `lib/features/*` |
| State | `flutter_bloc` 9 + `hydrated_bloc` (persisted state), blocs are lazy singletons, provided globally | `lib/services/service_provider.dart` |
| DI | `get_it` + `injectable` code generation | `lib/core/di/di_container.dart` |
| Routing | `go_router` 17, deep links via `app_links` | `lib/core/routes/router.dart` |
| API | Dio behind a small client abstraction, `/v2` prefix, `DeviceHeaderInterceptor`; Bunny for TUS uploads | `lib/core/api/*` |
| Auth/session | JWT in **SharedPreferences** (`PrefsRepository.token`), backend `JWT_EXPIRES` default **365d**, no refresh flow in use, **no logout endpoint** (logout clears local data only) | `core/storage/prefs_repository_impl.dart`, `coursaty/src/modules/auth/auth.module.ts`, `url_routes.dart` |
| Local data | SharedPreferences, hydrated bloc JSON, `flutter_cache_manager`, `flutter_secure_storage` (device ids, offline video keys), encrypted offline HLS | `lib/services/device_info_service.dart`, `my_downloads/data/services/*` |
| UI scaling | `flutter_screenutil` with design size **375×812** used throughout (`.w/.h/.r/.sp`); only 8 files use `MediaQuery`/`LayoutBuilder` | `core/common/constant/design/constant_design.dart` |
| Platform branches | 18 `Platform.is*/defaultTargetPlatform` checks | `lib/` |
| Tests/CI | 178 unit/widget tests pass; no CI configuration in the repo | `test/` |

### 2.2 Strengths
- Business logic, models, API layer, blocs and most widgets are plain Dart and reusable unchanged.
- Security decisions already sit behind small interfaces that a desktop implementation can plug into:
  `ScreenCaptureController` (`core/security/screen_capture_policy.dart`), `VideoDeviceKeyService`
  (`isSupported` flag), `PaidContentPolicy`, the playback proxy (pure `dart:io`, runs in its own isolate).
- Video access is already server-driven: playback sessions, challenges, device proofs, gateway mode.

### 2.3 Weaknesses / constraints
- The player stack is mobile-only (`better_player_plus`), and the zoom, controls and seek code is built on it.
- Phone-first layout scaled by ScreenUtil; no adaptive layouts.
- Long-lived bearer token in plain storage; no server-side session invalidation.
- Several security checks are Android-only (Keystore device key, Play Integrity, emulator signals);
  iOS already runs with weaker guarantees (no device key bridge) [V].

---

## 3. Desktop compatibility matrix

Platform support was read from each resolved package's own `pubspec.yaml` (`flutter.plugin.platforms`) [V].
Legend: ✅ works as is · 🟡 minor adaptation · 🟠 significant change · ❌ unsupported, needs an alternative · ❓ needs a proof of concept.

| Feature / package | Windows | macOS | Linux | Required change |
|---|---|---|---|---|
| Pure-Dart packages (bloc, go_router, dio, get_it, dartz, easy_localization, cached_network_image, flutter_svg, google_fonts, hydrated_bloc, tusc, http, cryptography, crypto…) | ✅ | ✅ | ✅ | none |
| **Video playback — `better_player_plus` 1.2.1** | ❌ | ❌ | ❌ | **Replace on desktop** with a desktop player behind a player interface (candidates: `media_kit` (libmpv) or `video_player` + platform implementation) ❓. Re-do controls, zoom, seek merging, buffering on it. |
| Online playback proxy (`online_playback_proxy.dart`, `dart:io`) | ✅ | ✅ | ✅ | none (loopback server + isolate) |
| `shared_preferences`, `path_provider`, `package_info_plus`, `url_launcher`, `connectivity_plus`, `device_info_plus`, `wakelock_plus`, `file_picker`, `image_picker`, `share_plus`, `app_links` | ✅ | ✅ | ✅ | deep-link registration per OS 🟡 |
| `flutter_secure_storage` 10.3.4 | 🟡 DPAPI-encrypted file, current-user scope [V] | 🟡 Keychain | 🟠 libsecret, needs a running keyring | Move token here (see §5) |
| `firebase_core` | ✅ | ✅ | ❌ | — |
| `firebase_messaging` | ❌ | ✅ | ❌ | Push on Windows: none, or poll/WebSocket 🟠 |
| `firebase_crashlytics` | ❌ | ✅ | ❌ | Windows crash reporting: e.g. Sentry ❓ |
| `no_screenshot` 0.3.6 | ❌ | 🟡 `sharingType` only, weak on macOS 15+ [D] | ❌ no-op [V] | Windows: own native call to `SetWindowDisplayAffinity` |
| `fluttertoast` | ❌ | ❌ | ❌ | Use SnackBar/overlay 🟡 |
| `root_checker_plus`, `device_safety_info` | ❌ | ❌ | ❌ | Desktop equivalent: VM / remote-session detection 🟠 |
| `get_thumbnail_video` (teacher upload) | ❌ | ❌ | ❌ | Not needed if desktop is watch-only; else server-side thumbnails |
| `cryptography_flutter` | falls back to pure Dart | ✅ | pure Dart | fine (no offline decryption on desktop) |
| `gal` (save to gallery) | ✅ | ✅ | ❌ | not needed on desktop |
| `pdfrx` (PDF viewer, FFI) | ✅ | ✅ | ✅ | 🟡 check file-protection rules |
| Native Android/iOS channels (`coursaty/video_security`: device key, Play Integrity, login device id, emulator signals; download keep-alive) | ❌ | ❌ | ❌ | New desktop plugin(s): capture exclusion, TPM/Secure Enclave key, VM/RDP detection 🟠 |
| Notifications (local/background) | 🟠 | 🟡 | 🟠 | Optional for v1 |
| Background execution | n/a | n/a | n/a | Not needed (online only) |
| Window/lifecycle | 🟡 | 🟡 | 🟡 | Minimum window size, single instance, fullscreen player, pause on minimise |
| Packaging | MSIX or installer + signing | .app/.dmg + notarization | — | see §5.G |

---

## 4. Security parity matrix

| Control | Android (today) | iOS (today) | Windows (possible) | macOS (possible) | Linux | Residual risk on desktop |
|---|---|---|---|---|---|---|
| Screenshot / recording block | `FLAG_SECURE` via `no_screenshot` [V] | iOS secure-field technique via `no_screenshot` [V] | `WDA_EXCLUDEFROMCAPTURE` — strong vs software capture [D] | `sharingType=.none` weak on 15+; **FairPlay** for real protection [D] | none | Camera, HDMI capture, virtual display drivers, VMs (detectable) |
| Content in protected path (DRM) | none (HLS + signed/gateway) | none | Widevine L3 gives **no** capture protection [D]; PlayReady not offered by Bunny [D] | FairPlay via Bunny Enterprise [D] | Widevine L3 only | — |
| Links work in app only (S2) | gateway + device-key proof **if enabled in prod** [V: off by default in `.env.example`] | gateway, **no device key** [V] | gateway + TPM-backed device key + IP-bound session + pinning (to build) | same with Secure Enclave key, or FairPlay licence | — | Token theft from memory by malware under the same user; replay inside TTL |
| Device-bound session | Keystore EC key (non-exportable) [V] | none [V] | CNG "Platform Crypto Provider" (TPM) non-exportable key ❓ | Secure Enclave key (Apple Silicon/T2) ❓ | software only | Machines without TPM 2.0 fall back to DPAPI-wrapped key |
| Emulator/VM refusal | native signals [V] | Simulator/Mac refused [V] | CPUID hypervisor bit, VM vendors, `SM_REMOTESESSION` ❓ | VM model check ❓ | — | Hardened VMs can hide |
| Root/jailbreak | `root_checker_plus` | same | n/a (admin users are normal) | n/a | n/a | — |
| Token storage | plain SharedPreferences (**weak**) | plain NSUserDefaults (**weak**) | DPAPI (current user) | Keychain | libsecret | Same-user malware can still read |
| Session lifetime/revocation | 365-day JWT, no server logout | same | needs short access token + refresh + server revoke | same | — | — |
| TLS / pinning | OS trust, no pinning; Android ignores user CAs by default [D] | OS trust | OS trust **includes user-installed CAs** → MITM easy without pinning | same | same | Pinning raises the bar; patched binaries can remove it |
| Clipboard / printing / export | n/a for video | n/a | Video frames cannot be copied while excluded; disable text copy where needed | same | — | — |
| Logs | request logging only in debug builds [V] | same | same | same | — | — |
| Crash reports | Crashlytics (no personal data) [V] | Crashlytics | Sentry or none ❓ | Crashlytics | — | — |

---

## 5. Security findings

| ID | Severity | Finding | Affected | Remediation |
|---|---|---|---|---|
| F1 | **Critical (Linux)** | No API exists to block capture on Linux; S1 impossible. | `no_screenshot` linux impl [V] | Do not ship Linux, or ship without protected video. |
| F2 | **High (macOS)** | `sharingType=.none` is reportedly ignored by ScreenCaptureKit on macOS 15+. | `no_screenshot` macOS impl [V], reports [D] | FairPlay DRM playback (Bunny Enterprise) + custom AVPlayer plugin; verify by PoC. |
| F3 | **High (desktop), Medium (mobile)** | Login JWT valid 365 days, stored in plain SharedPreferences; logout is local only. On Windows that is a readable file in the user profile. | `prefs_repository_impl.dart`, `auth.module.ts` [V] | Short-lived access token (≤ 1 h) + refresh token in secure storage, server-side logout/revocation, refresh-token rotation. Apply to mobile too. |
| F4 | **High (desktop)** | No certificate pinning. Desktop users can trust their own root CA and read every API response (session tokens, signed video URLs). | `di_container.dart` Dio setup [V] | Pin the backend and gateway certificates (SPKI pins with a backup pin), refuse user-added roots. |
| F5 | **High** | Default video mode issues signed Bunny URLs valid 300 s that play **in any browser**; gateway/app-only/device-signature enforcement are off in `.env.example`. If production matches, S2 is not met even on mobile. | `videos.service.ts`, `.env.example` [V]; production env not visible ❓ | Turn on `VIDEO_EDGE_GATEWAY_ENABLED`; bind gateway sessions to user + device + client IP; one concurrent session per account; short TTL with renewal. |
| F6 | **High (desktop compatibility)** | "App-only" mode verifies **Google Play Integrity**; desktop clients can never pass it. | `videos.service.ts` `verifyPlayIntegrity` [V] | Per-platform policy: Play Integrity for Android, App Attest for iOS, TPM-key proof + signed binary checks for Windows. |
| F7 | **Medium** | Device-key proof exists only on Android; iOS has none. | `video_device_key_service.dart` [V] | Add Secure Enclave key on iOS/macOS, TPM key on Windows. |
| F8 | **Medium** | No visible watermark: a camera or capture-card recording cannot be traced to a student. | no watermark code [V] | Moving, semi-transparent watermark with the student's id/phone fragment over the player (all platforms). |
| F9 | **Medium** | `VIDEO_DEVICE_LIMIT=1` revokes the least recently used device, so a phone and a desktop would keep revoking each other. | `videos.service.ts` [V] | Business decision: allow 1 phone + 1 desktop, or desktop-only seats. |
| F10 | **Low** | `.env.example` shows a placeholder `JWT_SECRET`. | `coursaty/.env.example` [V] | Confirm production uses a long random secret (not checked; secrets were not opened). |
| F11 | **Low** | Firebase client config is embedded (normal for Firebase, not a secret). | `lib/firebase_options.dart` [V] | Restrict API keys by app/bundle id in Google Cloud console. |

### 5.A–G summary of the security model for Windows (recommended)

- **A. Session:** short access token + rotating refresh token in DPAPI storage; server logout; device
  registration with a TPM-backed, non-exportable key; every playback session proves possession of it.
- **B. Local data:** online only, so no video data at rest; no response caching of protected endpoints;
  the HTTP image cache holds only thumbnails; wipe secure storage on logout.
- **C. Reverse engineering:** release with `--obfuscate --split-debug-info`; no secrets in the binary
  (none found [V]); all enforcement stays on the server. Obfuscation slows analysis, it does not stop it.
- **D. Content:** capture exclusion on the main window and every pop-up/fullscreen window, re-asserted
  periodically and checked with `GetWindowDisplayAffinity`; refuse playback under a VM or a remote
  session; watermark; pause on minimise.
- **E. Network:** TLS with pinning; gateway mode; sessions bound to device key and IP; rate limits
  (already present [V]); revocation on device replacement (already present [V]).
- **F. Threat model:** see §10.
- **G. Distribution:** MSIX or Inno Setup installer signed with a code-signing certificate; the app
  checks a signed update manifest (reuse the existing admin-controlled app-update policy endpoint [V]);
  SHA-256 of the installer published and verified before install.

---

## 6. Recommended architecture

**Option A — one Flutter project with adaptive layouts and platform adapters (recommended).**

- Same repository, add `windows/` (later `macos/`). Shared data/domain/bloc layers unchanged.
- New thin abstractions where behaviour differs, chosen at startup by platform:
  - `VideoPlayerView` / `PlaybackController` interface — `BetterPlayerAdapter` (mobile, current code)
    and `DesktopPlayerAdapter` (new).
  - `ScreenCaptureController` — existing interface; add `WindowsCaptureController`
    (native `SetWindowDisplayAffinity`) and `MacCaptureController`.
  - `DeviceKeyService` — add TPM (Windows) and Secure Enclave (Apple) implementations.
  - `TokenStore` — moves the JWT/refresh token from SharedPreferences to `flutter_secure_storage`.
  - `DeviceIntegrity` — mobile: emulator/root; desktop: VM / remote session.
- Adaptive layout: breakpoints with `LayoutBuilder`; on desktop a sidebar + content area, content width
  capped (e.g. 1200 px); ScreenUtil disabled or locked to a desktop design size so widgets do not scale 5×.
- Desktop entry stays watch-focused: teacher upload screens can be hidden on desktop (v1).

Option B (shared logic + separate desktop presentation) duplicates many screens for little gain.
Option C (separate desktop app) duplicates everything, rejected. A rewrite is not justified.

---

## 7. UI/UX adaptation plan

- Replace ScreenUtil scaling on desktop (biggest single UI task): constrain content width, desktop
  typography scale, minimum window size ~1024×700.
- Navigation: bottom bar → side navigation rail on wide windows.
- Lists/grids: course cards in responsive grids instead of horizontal phone lists.
- Player page: video left/top with lecture list and seek points in a side panel; fullscreen with Esc;
  keyboard shortcuts (Space play/pause, ←/→ seek, F fullscreen, M mute); mouse wheel volume.
- Hover states, right-click disabled on protected content, text selection off where copying is unwanted.
- RTL and Arabic localisation already work in Flutter on desktop (same `easy_localization` assets).
- Multi-monitor/DPI: Flutter handles per-monitor DPI; capture exclusion applies on every monitor [D].
- Reusable as is: dialogs, chips, cards, forms (with width constraints), loading/error widgets.

---

## 8. Development roadmap (Windows first)

1. **PoC (3–5 days, isolated branch/worktree):** enable `windows/`, build; desktop player playing a
   gateway HLS stream through the existing proxy; `WDA_EXCLUDEFROMCAPTURE` test against Snipping Tool,
   Print Screen, Game Bar, OBS (window + display capture), Teams/Zoom share, Recall; secure storage
   check. Go/no-go gate.
2. **Backend:** short tokens + refresh + logout; gateway on; device/IP binding; desktop device-key
   registration; per-platform attestation policy; device-limit decision.
3. **App platform layer:** player adapter, capture controller, token store, device key, VM/RDP gate.
4. **Desktop UI:** adaptive layouts, navigation, player page, shortcuts.
5. **Hardening:** pinning, watermark, obfuscation, crash reporting.
6. **Packaging and updates:** signed installer, update check, release checklist.
7. **Testing:** Windows 10 22H2 / 11, Intel/AMD/NVIDIA GPUs, low-spec PC, mobile regression.
8. **macOS (optional, after Windows):** FairPlay via Bunny Enterprise, AVPlayer plugin, notarization.

---

## 9. Effort estimates [A]

Developer-days for one experienced Flutter developer. Assumes the backend is changed by the same team,
designs follow existing mobile UI, and no UI designer is involved.

| Work item | Windows best | expected | high | macOS extra (expected) |
|---|---|---|---|---|
| 1. Project preparation | 1 | 2 | 3 | 2 |
| 2. Compatibility fixes (player replacement incl. controls, zoom, seek) | 5 | 8 | 12 | 3 |
| 3. Shared architecture (adapters/interfaces) | 2 | 3 | 5 | 1 |
| 4. Desktop UI/UX | 7 | 10 | 15 | 2 |
| 5. Security (capture, device key, token store, VM/RDP, pinning, watermark) + backend | 8 | 11 | 16 | 12 (FairPlay) |
| 6. Platform integrations (deep links, crash reporting, update check) | 1 | 2 | 3 | 2 |
| 7. Automated tests | 2 | 3 | 4 | 2 |
| 8. Device/OS testing | 2 | 3 | 4 | 3 |
| 9. Packaging and distribution | 2 | 2 | 3 | 3 |
| 10. Production hardening | 1 | 1 | 2 | 1 |
| **Total** | **31** | **45** | **67** | **≈ 31** |

- **Minimum viable Windows** (player, capture block, basic adaptive UI, gateway on, signed installer):
  ≈ 25 days. **Production-ready** as in the table: ≈ 45 days.
- Confidence: medium for Windows (the player replacement is the main unknown); low for macOS (FairPlay
  integration effort and Apple/DRM account availability).

---

## 10. Risk assessment

| Risk | Severity | Likelihood | Mitigation | Residual |
|---|---|---|---|---|
| Phone camera / HDMI capture card | High | Medium | Visible moving watermark, account bans | Cannot be prevented |
| Running the app in a VM and recording the host | High | Medium | Refuse on hypervisor/VM detection | Hardened VMs |
| Virtual display driver / mirror driver | Medium | Low | Detect unusual display adapters (best effort) | Possible bypass |
| DLL injection clearing the affinity flag | Medium | Low | Re-assert + verify periodically; signed binary; integrity checks | Determined attackers |
| Token theft by malware (same user) | High | Low | Short tokens, device-key proof, IP binding, revocation | Live session abuse until expiry |
| MITM with user CA | High | Medium | Certificate pinning | Patched binary |
| Binary patching to skip checks | Medium | Medium | Server enforcement, obfuscation, code signing | Client checks are deterrents |
| Shared computers / multiple OS users | Medium | High (labs) | DPAPI per user, logout wipes data, no offline content | — |
| Untrusted updates | High | Low | Signed installer + signed manifest + hash check | — |
| Unauthorized installs | Low | Medium | Account/device limit, server checks | — |
| Desktop player stability/performance | Medium | Medium | PoC on low-spec PCs first | — |
| Account/payment availability (code signing CA, Apple Developer, Bunny DRM) for a Syria-based business | High | Unknown | Check before committing; use an available legal entity/reseller | May block macOS/DRM |
| Phone + desktop revoking each other (device limit 1) | Medium | High | Decide the seat policy | — |

---

## 11. Validation and testing strategy

- **Isolated work:** separate branch/worktree; mobile builds and the 178 existing tests must stay green on every change.
- **Capture test matrix (Windows):** Snipping Tool, Print Screen, Win+Shift+S, Xbox Game Bar, OBS
  (window, display, game capture), ShareX, Teams/Zoom/Meet screen share, Windows Recall, RDP session,
  VirtualBox/VMware/Hyper-V guest. Expected: window absent or black, or playback refused.
- **S2 tests:** copy a playback URL/token out of the app (debug proxy with user CA → must fail due to
  pinning); replay a captured gateway URL from curl/another PC/another IP → 403; replay after logout → 403.
- **Auth:** token not readable from SharedPreferences files; refresh, expiry, logout revocation.
- **Performance targets [A]:** cold start < 3 s on a mid PC; 1080p playback with < 1% dropped frames;
  memory < 400 MB during playback; seek response < 500 ms; idle CPU < 2%.
- **Low-spec check:** 4 GB RAM, integrated graphics, Windows 10.
- **Mobile regression:** full test suite + manual smoke on Android/iOS after each shared-layer change.

---

## 12. Final recommendation

Build **Windows first**: it is where most Syrian students' computers are [A], and it is the only desktop
OS that offers a dependable, documented API to keep the window out of software screen capture. Start
with the 3–5 day proof of concept in §8 and decide after it. Treat **macOS** as a second phase only if
the client accepts FairPlay DRM costs and Apple account requirements. **Do not build Linux** for this
product: the screen-capture requirement cannot be met there.

Be explicit with the client: S1 can be enforced against screenshot and recording **software** on
Windows, but nothing stops a camera pointed at the screen; the watermark is the answer to that. S2 is a
backend property: links stop working outside the app only after the gateway, device binding and
pinning work in §5 is done, and that also improves the mobile apps.

---

### Sources
- Microsoft: SetWindowDisplayAffinity / WDA_EXCLUDEFROMCAPTURE — summarised in
  [meziantou.net](https://www.meziantou.net/how-to-exclude-your-windows-app-from-screen-capture-and-recall.htm),
  limits in [IOActive: "The DRM flag that isn't DRM"](https://www.ioactive.com/the-drm-flag-that-isnt-drm/),
  [Habr](https://habr.com/post/1025310/)
- macOS 15 ScreenCaptureKit and `sharingType`:
  [Product Hunt write-up](https://www.producthunt.com/p/jobpath/how-apps-hide-windows-from-screen-capture-and-what-broke-in-macos-15),
  [Apple Developer Forums](https://developer.apple.com/forums/thread/69290)
- Bunny MediaCage DRM: [docs](https://docs.bunny.net/stream/drm),
  [Enterprise](https://bunny.net/stream/media-cage-enterprise-multi-drm-digital-rights-management),
  [pricing](https://bunny.net/docs/stream/pricing)
- Package sources: resolved `pubspec.yaml` of every dependency; `no_screenshot` 0.3.6 linux/macos
  sources; `flutter_secure_storage_windows` 4.1.0 (DPAPI).
