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
- Besides the unit tests, the practical way to validate a change against the real backend is the same
  one used in the admin project: have the user log in and save the token, then drive the app's real
  data sources from a throwaway `test/zz_tmp_*.dart` (Dio + token in headers) and delete it afterwards.
  See BACKEND_API.md.
