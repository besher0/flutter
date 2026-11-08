# Coursaty Student & Teacher App — project context

> Written 2026-10-17 from the actual code, corrected the same day after a full review of the three
> projects. Facts marked **(verified live)** were confirmed against the real backend. Everything else
> describes code that can change — check the code before relying on a specific line.

## What this is

`coursaty_student_and_teacher` is the **end-user** Flutter app of Coursaty, an Arabic (RTL) e-learning
platform for Syrian universities. **One binary, two roles:**

- **Student:** browses their college/year content (subjects, programs, teachers), subscribes to courses
  with an activation code, watches lectures (videos with resolutions, files, MCQ questions), downloads
  content for offline use, rates courses, likes teachers.
- **Teacher:** creates and manages courses, lectures, videos (resumable upload), files and questions,
  sees revenue/withdrawals, sends notifications, manages affiliations (college/department).

**Workspace layout** (`C:\Users\Mahmoud\Desktop\coursaty modified\`): `coursaty/` = NestJS + Prisma
backend (GitHub `besher0/coursaty`, deploy branch `main`), `coursaty_a/` = admin dashboard (same
backend), `flutter/` = this app. This app is the **design/source-of-truth reference** that the admin
app copies from (cards, chips, players, response shapes).

Scale: ~334 Dart files, ~42.5k lines under `lib/`.

## Repo facts

- Git repo, remote `github.com/besher0/flutter`, working branch **`fix/video-security-integration`**
  (plus `main`), version `2.1.0+6`. Releases are distributed outside Google Play too
  (`RELEASING_OUTSIDE_PLAY.md`).
- Toolchain (2026-11-03): **Flutter 3.47.9 / Dart 3.13.7**, Gradle wrapper **8.14.3**, Android Gradle
  Plugin **8.11.1** (Flutter 3.47 refuses older Gradle/AGP). `pubspec.lock` needs this SDK (`meta 1.19`).
- `flutter analyze`: keep errors at 0; don't mass-fix the pre-existing infos/warnings.
- **Tests exist** under `test/` (`core/`, `app/`, `features/…`, `fixtures/device_proof_contract.json`):
  `/v2` routing + device header, revenue models/widgets, screen-capture policy, downloads expiry,
  resumable upload, subscriptions. Run `flutter test` (or a single file) before finishing.

## Stack

- Dart SDK `^3.11.1`, Flutter, Material 3, `MaterialApp.router`
- **State:** `flutter_bloc` 9 + `hydrated_bloc` (persisted `AppBloc`), `bloc_concurrency`, `stream_transform`
- **DI:** `get_it` + **`injectable` with code generation** (`lib/core/di/di_container.dart` and the
  generated `di_container.config.dart`). ⚠️ Adding an `@injectable` class or a new constructor
  parameter requires `dart run build_runner build --delete-conflicting-outputs`. To avoid codegen,
  add a *method* to an existing injected class and resolve inline with `GetIt.I<X>()` — that is already
  the pattern inside `AppBloc`.
- **Routing:** `go_router` 17 — `lib/core/routes/router.dart` (tree) + `router_config.dart`
  (`_ApplicationRoutes` holds every path string). Deep links via `app_links`.
- **HTTP:** `dio`, but calls go through a small client abstraction (below), not raw `dio` in features
- **Errors:** `dartz` `Either<Failure, T>` + `HandlingExceptionRequest` mixin (`core/api/handling_exception.dart`)
- **Storage:** `shared_preferences` behind `PrefsRepository` (keys are obfuscated strings in
  `core/common/constant/configuration/prefs_key.dart`), `flutter_cache_manager`
- **Push:** `firebase_core` + `firebase_messaging` (`lib/services/notification_service/`)
- **Media:** `better_player_plus`, `pdfrx`, `get_thumbnail_video`, `tusc` (resumable/TUS video upload)
- **i18n:** `easy_localization` with `assets/languages/`
- **Sizing:** `flutter_screenutil`, `kDesignSize = Size(375, 812)` — `.r/.h/.w/.sp` are used throughout
  (unlike the admin app, which uses its own context extensions)
- **Fonts:** `google_fonts` (Cairo)
- **Security / anti-tamper:** `no_screenshot` (screenshots off app-wide), `root_checker_plus`,
  `device_safety_info`, simulator detection, and an NTP check
  (`services/network_time_protocol_service.dart`) that routes to `fraud_date_page.dart` when the device
  clock is faked. Dedicated gate pages at `lib/`: `blocked_account_page.dart`, `outdated_app.dart`,
  `the_device_is_rooted_page.dart`, `application_run_in_simulator_page.dart`.

## Startup

`lib/main.dart`: Firebase init → `HydratedBloc.storage` → `Future.wait([EasyLocalization.ensureInitialized(),
configureDependencies(), NotificationProcess.init(), DeviceInfoService.init()])` → date-fraud check →
`runApp(CoursatyApp())`. `lib/coursaty_app.dart` wraps `ScreenUtilInit` → `LocalizationService` →
`ServiceProvider` (global bloc providers) → `MaterialApp.router` with `AppTheme.light/dark` chosen from
`AppBloc.state.isThemeLight`, and `textScaler: TextScaler.noScaling`.

Test accounts are noted in a comment at the top of `main.dart` (student / teacher phones).

## Architecture

Per feature under `lib/features/<feature>/`: `data/{model,source,repository}`,
`domain/{repository,use_case}`, `presentation/{bloc,pages|screens,widgets}`.

Top level also has: `lib/app/widgets/` (shared dialogs, players, text fields, chips),
`lib/app/blocs/sensitive_connectivity/`, `lib/core/`, `lib/services/`.

### The request pattern (important — not plain dio)

`core/api/`:
- `base_api.dart` — `BaseApi<T>`: pulls the bearer token from `GetIt.I<PrefsRepository>().token`, adds a
  `User-Agent`, exposes `client` (`GetIt.I<Dio>()`) and `options`.
- `client_config.dart` — `RequestConfig<T>{endpoint, response, queryParameters, data, timeouts}` and
  `ResponseValue<T>{fromJson | returnValueOnSuccess}` (exactly one must be non-null).
- `methods/get.dart`, `methods/post.dart`, … — `GetClient<T>` / `PostClient<T>`, constructed with a
  `serverName` + `requestPrams`, then **called like a function**.
- `detect_server.dart` — `enum ServerName { master, bunny }`; base URI/token per server.
  Master API paths are prefixed with **`/v2`** (`MasterUrlRoutes.apiPath`, `apiPathFor`); a
  `DeviceHeaderInterceptor` sends `X-Coursaty-Device` (student single-device login) to the backend
  host only. `BunnyUrlRoutes.baseUrl = 'https://video.bunnycdn.com/'` (video library / TUS upload, no
  app token).
- ⚠️ `GetClient` builds a Dart `Uri`, which **throws on non-`String` query values**. `get.dart` now
  stringifies them, but keep sending strings (`'$page'`) — an `int` year/month is what broke every
  teacher-revenue period filter except «كل الفترات».

A data source method therefore looks like:

```dart
final GetClient<CourseRatingModel> req = GetClient(
  serverName: ServerName.master,
  requestPrams: RequestConfig(
    endpoint: EndPoints.getCourseRating(id: id),
    response: ResponseValue(fromJson: (json) => CourseRatingModel.fromJson(json)),
  ),
);
return req();
```

### Endpoints

All in `core/common/constant/configuration/url_routes.dart`. Paths are composed with **String scope
extensions**: `'me/summary'.teachersScope` → `teachers/me/summary`; also `authScope`, `usersScope`,
`studentsScope`, `academicsScope`, `coursesScope`, `dashboardScope`, `interactionsScope`,
`lecturesScope`, `uploadsVideosScope`, `noScope`. Add new endpoints there, not inline in features.
Bunny endpoints live in `bunny_url_routes.dart`.

### Blocs

All feature blocs are **globally provided** in `lib/services/service_provider.dart`
(`MultiBlocProvider` of `GetIt.I<XBloc>()` for Auth, Home, Teachers, Courses, App,
CourseContentManagement, DownloadingMedia, MyDownloads, Notifications, SalesPoints, plus a locally
constructed `SensitiveConnectivityBloc`) — a new bloc must be registered there too, or
`context.read<XBloc>()` will throw.

One bloc per feature, annotated `@LazySingleton()` (so they survive navigation and are injected),
use cases are `@injectable` and extend `UseCase<T, Params>` (`core/use_case/use_case.dart`) returning
`Either<Failure, T>`. Request state uses `RequestStatus` (`core/enums/request_status.dart`).

### Pagination (this app's own pattern — predates the admin app's)

`core/models/pagination_model.dart`: `const int kPageSize = 15;`, `enum PaginationStatus
{initial, success, failure, loading}`, and `PaginationModel<T>{items, page, paginationStatus,
hasReachedMax}` with `copyWith` + `isLoading/isSuccess/...`.
State fields are `PaginationModel<X>` (e.g. `coursesOfSubject`, `teacherActiveCourses`), the bloc sends
`page`/`limit: kPageSize` and sets `hasReachedMax: returnedCount < kPageSize`, and screens trigger the
next page with

```dart
NotificationListener<ScrollNotification>(
  onNotification: (scrollInfo) {
    if (scrollInfo.metrics.pixels >= 0.7 * scrollInfo.metrics.maxScrollExtent) { /* add LoadMore event */ }
    ...
```

Note the backend added `pagination` objects to several admin endpoints on 2026-09-27 (see
BACKEND_API.md); teacher/student endpoints that already paged (`teachers/me/courses/active|expired`,
withdrawals, `dashboard/*`) are the ones this app consumes.

## Design system (what the admin app mirrors)

- `core/theme/app_colors.dart` + `app_theme.dart` (light & dark), `core/common/constant/design/constant_design.dart`
  (`kBr8/kBr10/kBr12`, `kbrCardRounded = 15.r`, `kDesignSize`, `kTextFieldHeight`…)
- `lib/app/widgets/chip_widget.dart` — `ChipWidget(iconPath, text, iconColor)`: padding 8/8, radius 11,
  `AppColors.chipBackground`, SVG icon height 12.5, text 10/w600 Cairo, color `primaryDarkActive`
- `features/courses/presentation/widgets/course_card.dart` — `width: 0.8.sw`, radius 10, padding 10/15,
  `Expanded` image, title 20/w700 ellipsis, chips in a horizontal `SingleChildScrollView`, optional footer
- `features/home/presentation/widgets/subject_card.dart` — height 110, image 157×83 radius 12,
  title 16/w700, horizontally scrolling chips (semester / year / teacher)
- Shared dialogs & players in `lib/app/widgets/`: `my_video_widget_better_player.dart`,
  `video_quality_dialog.dart` / `pick_resolution_dialog.dart`, `activate_code_dialog.dart`,
  `subscribe_to_course.dart`, `paid_content_dialog.dart`, `you_are_guest_dialog.dart`,
  `question_info_dialog.dart`, `zoomable_image.dart`, `try_again_widget.dart`

## Feature map (`lib/features/`)

| folder | what's in it |
|---|---|
| `courses` (56 files) | course/lecture/video details, courses by subject & year, teacher course pages, MCQ screen, decrypted-PDF viewer, `course_card`, `lecture_item`, rating |
| `auth` (39) | login, signup (student/teacher), guest creation, edit profile, change password, change university/year, blocked account |
| `home` (36) | student home + content, subjects, programs, search, subscriptions, ads preview, **teacher home** with metric cards |
| `teachers` (29) | teachers list, teacher detail/profile, affiliations (+add), revenue, withdrawals |
| `course_content_management` (29) | teacher-side creation: add course, upsert lecture, add video (TUS), add file, upsert question, select subject |
| `norifications` (14) | ⚠️ directory name is misspelled in the repo — notifications list, teacher notifications, add notification |
| `app` (13) | about app (now API-driven), contact us, customer service, `AppBloc` (theme, app-level data) |
| `sales_points` (11) | points-of-sale list + detail |
| `my_downloads` (11) | offline downloads, downloading-media bloc, downloaded course/lecture details |
| `onboarding`, `common` | intro slides; shared models/use cases |

## Conventions & gotchas

- **Arabic-first, RTL.** User-facing strings are Arabic literals or `easy_localization` keys
  (`assets/languages/`). Keep identifiers English.
- Use **ScreenUtil units** (`.r/.h/.w/.sp`) and the `constant_design` constants — do not hardcode raw
  pixels in new UI here (the admin app's `context.hX` scale does **not** exist in this project).
- **Codegen boundary:** anything that changes injectable graph wiring needs `build_runner`. Prefer
  adding methods to existing classes (`AppRepository`, `AppBloc`) and `GetIt.I<...>()` inline.
- Screenshots are disabled app-wide (`no_screenshot`) — screen recording/capture during manual QA won't work.
- Downloaded content is stored encrypted/decrypted through the downloads feature; there is a dedicated
  `pdf_viewer_for_decrypted_files_page.dart`. Don't route offline files through the normal viewer.
- Videos (video-security update): the backend no longer sends `videoUrl` in lecture details. Playback
  goes through `POST videos/{id}/playback-session` (challenge + device-key proof for students, see
  `my_downloads/data/services/video_access_service.dart`) and returns an HLS URL — for teachers and
  gateway-mode students a Bunny edge-gateway URL that needs the `X-Coursaty-Playback-Session` header
  on every request. Downloads use `download-session` + an offline license. Qualities come from
  `uploads/videos/{id}/resolutions`, `playlistResolutions` first. Players hold a wake lock
  (`app/widgets/playback_wakelock.dart`).
- Online playback goes through a loopback proxy (`my_downloads/data/services/online_playback_proxy.dart`)
  that runs **in its own isolate** (every segment byte passes through it; on the UI isolate that made the
  player feel heavy). The player opens one local URL for the whole viewing and a session renewal only
  swaps the proxy's upstream token/header (`await updateUpstream`). ⚠️ Never renew by calling
  `setupDataSource` while playing — better_player hides the video until the next play event, which was
  the black flash every ~4 minutes (signed URLs live 300 s).
- Player performance rules (`app/widgets/my_video_widget_better_player.dart`): the controller is a
  `SmoothSeekBetterPlayerController` (`smooth_seek_controller.dart`) — better_player's progress bars seek
  on every drag update (~60/s), so seeks are merged (one at a time, ≥300 ms apart, ending at the last
  position). Every data source carries `_buffering` (max 50 s ahead): better_player's default max buffer
  is ~109 minutes, which let ExoPlayer hold ~130 MB in Java heap and could close the app (OOM).
- Pinch zoom (Android and iOS) scales only the picture; better_player draws no controls inside the
  player (`BetterPlayerTheme.custom` + empty builder) and `_zoomable` draws the platform's controls
  (`BetterPlayerMaterialControls` / `BetterPlayerCupertinoControls`) above it. A small reset button sits
  at the top right while zoomed (below the cupertino top bar on iOS). iOS zoom transforms a platform
  view (UiKitView) and has not been checked on an iPhone yet.
- Crash reporting: Firebase Crashlytics (`services/crash_reporting.dart`, started in `main.dart` right
  after `Firebase.initializeApp`; off in debug builds). Native crashes come from the SDK (Android NDK
  library included, same BoM as `firebase_core`); Dart framework/zone/isolate errors from
  `CrashReporting.init`. Use `CrashReporting.log` for breadcrumbs and `recordError` for handled errors;
  the player logs open/ready/exception/close. Never send personal data (only the `role` key is set).
  iOS: symbol (dSYM) upload needs the Crashlytics run-script build phase in Xcode — not added yet.
- Real-device gate (`services/device_info_service.dart` + native `EmulatorSignals.kt`): **only emulators
  are refused, never a real device.** Android refuses on proof only: an emulator build/name, QEMU
  kernel/hardware properties, a desktop emulator's own files (BlueStacks, Nox, LDPlayer, MEmu,
  Genymotion, VirtualBox), an x86 CPU under a hypervisor (a PC virtual machine; Chromebooks excepted),
  or a QEMU trace/emulated sensor together with x86 or a hypervisor. No accelerometer, an x86 CPU alone,
  a generic fingerprint, QEMU leftovers or a failed check never refuse. iOS refuses the Simulator and
  iPhone apps on a Mac. Tests list both sides in `test/features/mobile_reliability_test.dart`.
- Studied videos (online and downloads, students/guests): local store
  `features/study_progress/data/study_progress_store.dart` (`StudyProgressStore.instance`, a
  `ChangeNotifier` over SharedPreferences, key per account; marks survive deleting a download). A
  lecture is studied when **all** its videos are: the full video list is remembered from the server's
  lecture details when the online lecture page loads (`rememberLectureVideos`, overwrite); a download's
  snapshot only fills a gap (`overwrite: false`). UI in `study_progress/presentation/widgets/studied_toggle.dart`:
  `VideoStudiedToggle` (cards + video page top bar), `LectureStudiedBadge` (lecture lists via
  `LectureItem.trailing`), `LectureStudyProgress` (under lecture titles, «درست X من Y فيديو»). Not in
  `MyDownloadsState`. ⚠️ Never filter the saved `LectureDetailsModel` lists in place (copy them first).
- iOS universal links: `ios/Runner/Runner.entitlements` (`applinks:coursay.duckdns.org`, linked via
  `CODE_SIGN_ENTITLEMENTS`); server file `.well-known/apple-app-site-association` (paths `/teacher`,
  `/course`, `/lecture`; app id `XT693D4UPT.com.YamanKartal.coursatyApp`). The App ID needs the
  Associated Domains capability in the Apple Developer portal.
- Course pages (online `course_details_screen.dart` and downloaded `downloaded_course_details.dart`)
  show three links as plain icon + label (`CourseLinkTile`, vector `AppAssets.telegramLogo`): Coursaty's
  Telegram channel and Instagram page (`CoursatySocialLinks` in
  `core/common/constant/configuration/social_links.dart`), then the course's teacher group
  (`telegramUrl`, subscribers only, hidden on the iPhone with paid content).
- **Windows desktop** (branch `feat/windows-desktop`, teachers first): one codebase. Ask
  `AppPlatform` (`core/platform/app_platform.dart`) before using a phone-only plugin — no Windows
  version: better_player, fluttertoast, firebase_messaging/crashlytics, no_screenshot,
  root_checker_plus, device_safety_info, get_thumbnail_video, cryptography_flutter. Startup skips
  Firebase, the emulator gate and the update check there. Video: `DesktopVideoPlayer` (media_kit,
  libmpv bundled for Windows only) inside `MyVideoWidgetBetterPlayer`; never add
  `media_kit_libs_android_*`/`_ios_*` (would bundle libmpv into the phone apps, which play with
  better_player). Layout: ScreenUtil is 1:1 on
  desktop and measures the centred 1280-px frame (`coursaty_app.dart`), so `.w/.h/.sp` are plain
  pixels and `1.sw` is the frame width; use `AppLayout.isWide`, `AdaptiveCardRow`, `DesktopFormWidth`,
  `AppLayout.courseCardWidth` for desktop-aware sizes. ⚠️ Mouse drag is **not** on app-wide: it made scrolling pages swallow clicks on the
  desktop video controls; wrap a horizontal list in `HorizontalMouseDrag` instead. Plain-file/URL
  players (upload preview, ad preview) use `SimpleDesktopVideo` on desktop. ⚠️ HTTPS on Windows needs the bundled Mozilla
  roots (`DesktopTls`, loaded in `main` and passed to the proxy isolate): a new isolate that makes
  HTTPS requests must call `DesktopTls.trustInThisIsolate`. Build: `flutter build windows`.
- Besides the unit tests, the practical way to validate a change against the real backend is the same
  one used in the admin project: have the user log in and save the token, then drive the app's real
  data sources from a throwaway `test/zz_tmp_*.dart` (Dio + token in headers) and delete it afterwards.
  See BACKEND_API.md.
