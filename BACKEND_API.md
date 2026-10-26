# Coursaty backend — contract notes (shared by both apps)

> Identical copies of this file live in `coursaty_a` (admin) and `coursaty_student_and_teacher`.
> Everything below was **verified against the live server** on the dates given, because swagger
> documents request parameters but **not responses**. Re-verify before trusting a shape that matters.

## Where the contract is

- Base URL: `https://coursay.duckdns.org/v2/` (NestJS). **Every app route lives under `/v2`**
  (URI versioning, 2026-10-10); unversioned paths answer `426 APP_UPDATE_REQUIRED`. Only
  `/internal/video-edge/*` (Bunny edge script) is unversioned. The admin app's `AppUrls.baseUrl`
  (`http://64.23.251.1:3000`) is stale (still used by the ads TUS upload) — the real base URL is in
  `core/api/client.dart`; the student app keeps it in `MasterUrlRoutes`.
- Backend source of truth: `coursaty/` (sibling folder), deploy branch **`origin/main`** — read the
  code there for response shapes before probing. Deployed by hand (`docker compose`), so the live
  server can lag behind `main`.
- Swagger UI: `/api` — **machine-readable OpenAPI: `/api-json`** (publicly readable, ~148 KB).
- Almost every response is declared as `200` with an empty/one-line description, so shapes come from
  live calls or from the student app's models.
- Video CDN is a **second server**: `https://video.bunnycdn.com/` (Bunny library + TUS upload), used by
  the student app via `ServerName.bunny`.

## Auth & how to probe safely

- `POST /auth/login` with the phone + password → `{accessToken, user: {id, phone, userableId,
  userableType: ADMIN|STUDENT|TEACHER, status, gender, fcmToken, createdAt}}`. Send
  `Authorization: Bearer <accessToken>` on everything else.
- The user has a **test admin account** (and student/teacher test accounts are noted at the top of the
  student app's `main.dart`). Ask them for credentials when needed — **don't hardcode them in the repo.**
- Established workflow: *the user runs the login themselves* in their terminal and saves the JSON to a
  scratchpad file; then only **GET** probing is done with that token. Their shell is
  **Windows PowerShell 5.1**, where `curl` is an alias for `Invoke-WebRequest` — give them
  `Invoke-RestMethod` commands.
- Handy ids for probing: university «جامعة حلب» = `00bbd93e-8f05-41e9-8675-fe40ee2638dd`.
  Universities list = `GET /academics/universities` (there is **no** `/universities`, it 404s).

## Contract changes since 2026-10 (read from the backend source on `origin/main`)

- **Lecture details strip `videoUrl`** from every video (`mapVideoMetadata`, since 2026-10-07), for
  admins too. Play by video id through `POST /videos/{id}/playback-session` (`{deviceId}` required):
  admins get a signed Bunny HLS URL valid `VIDEO_ADMIN_PLAYBACK_TTL_SECONDS` (3 h); teachers get an
  edge-gateway URL + `accessToken` sent in `X-Coursaty-Playback-Session`; students also need a
  challenge + device-key signature.
- `GET /uploads/videos/{id}/resolutions` → `{availableResolutions, playlistResolutions:
  [{resolution, sizeBytes}], mp4Resolutions: [{resolution, sizeBytes}], isPlayable, …}` — **no
  `path` any more**, and `mp4Resolutions` can be empty when MP4 fallback is off. Prefer
  `playlistResolutions`.
- Code batches: `GET /financials/code-groups` items and `GET /admins/codes/group/{id}` carry, at the
  root, `universityName`, `collegeName`, `departmentName`, `studyYearName` (added on branch
  `fix/codes-print-header-and-guards`), `subjectName`, `teacherName` — course links first, then the
  subject's, then the college year's (`course-print-header.ts`).
- Teacher withdrawals: `GET /teachers/{id}/withdrawals?page&limit` (default 20, max 50) →
  `{teacherEarnings, withdrawnAmount, remainingAmount, withdrawals: [{id, amount, status,
  createdAt}], pagination: {page, limit, total}}`. Amounts are numbers rounded to 2 decimals (can be
  `double`). `POST` the same path with `{amount, withdrawnAt?}`; `400 «قيمة السحب أكبر من الرصيد
  المتاح»` above the balance. `GET /teachers/{id}/revenue` returns `totals` and
  `withdrawals: {withdrawnAmount, remainingAmount, withdrawalCount}` (all-time).
- Revenue period filters (`/teachers/me/revenue`, `/teachers/{id}/revenue`, course statistics,
  `/admins/revenue`): `year` with optional `month`, **or** `dateFrom` + `dateTo` (`YYYY-MM-DD`,
  Asia/Damascus), never both.
- **Students vs subscriptions (2026-10-19).** "N طالب" everywhere = `StudentSubscription` rows
  (unique per student+course, a renewal rewrites the row) = `_count.subscriptions` /
  `studentsCount`. Revenue `subscribersCount` / invoice `totalSubscribers` = revenue transactions
  in the period **including renewals** — never label it as a student count. Course and teacher
  revenue responses now also send `studentsCount`, `subscriptionsCount`,
  `initialSubscriptions`, `renewals` (branch `fix/codes-print-header-and-guards`). Money and
  "this month" figures (teacher home, admin home, code statistics) come from revenue transactions
  in the Asia/Damascus month (`RevenueService.sumTransactions` / `damascusMonth`), not from
  subscription rows.
- **App updates (branch `fix/device-alt-id-app-update`).** `GET /app-updates/{android|ios}/check?build=N`
  (public) → `{updateAvailable, required, latestVersion, latestBuild, mode, storeUrl, downloadUrl,
  message}`; admins use `GET /app-updates` and `PUT /app-updates/{platform}` `{latestVersion,
  latestBuild, mode: FLEXIBLE|FORCE, storeUrl?, downloadUrl?, message?}`. `build` is the number after
  `+` in pubspec. The ST app checks at launch and on resume (`AppUpdateGate`).
- **iPhone paid content (same branch).** `GET /system-settings/app-config` (public) →
  `{iosPaidContentVisible}` (default false); admins `PATCH` it. The ST app's `PaidContentPolicy.hidePaid`
  (iOS only, cached, hidden until the server answers) hides prices, subscribe/QR/code activation,
  purchase requests, points of sale, the student's «اشتراكاتي» tab and locked videos/files/questions;
  for teachers, earnings (revenue card, revenue, withdrawals, course revenue tab) and the price/free
  fields of courses, videos and files (a new course is sent with price 0; the admin prices it).
- **Second student device id (same branch).** Login/sign-up also send `loginDeviceAltId` (hashed
  Widevine id, independent of the signing key). Stored as `User.loginDeviceAltId`; when
  `loginDeviceId` changes but this matches, the binding moves to the new id (a store install after an
  APK from outside the store). Cleared by the admin device reset.
- Admin set-password: `PATCH /admins/users/{userNumber}/password` `{password}` — looks the user up
  **by phone only**, and the password must be **≥ 8 characters** after trimming.
- Students sign in from one bound device (`X-Coursaty-Device` header / `did` in the token); admins
  reset it with `POST /admins/students/{id}/reset-login-device`, exempt accounts via
  `PATCH /admins/students/{id}/login-device-exempt`.
- Security (found 2026-10-17): `GET /financials/code-groups` and `GET /financials/codes` were
  **unauthenticated and return every activation code value**; `POST/PATCH/DELETE /point-of-sales`
  were unauthenticated too. All are ADMIN-only on branch `fix/codes-print-header-and-guards` — they
  stay open on the live server until that branch is deployed. `GET /admins` (admin profiles) is still
  public. Never probe the open code endpoints live.

## Pagination — added by the backend 2026-09-27 (verified live)

| endpoint | envelope |
|---|---|
| `GET /admins/users-directory` | `{type, pagination, items: [...]}` |
| `GET /admins/dashboard/courses/subjects` | `{subject, courses: {data: [...], pagination}}` |
| `GET /admins/dashboard/courses/programs` | `{program, courses: {data: [...], pagination}}` |
| `GET /admins/dashboard/courses/subject` | alias of `…/subjects` (added same day) |

`pagination = {page, limit, total, totalPages, hasNextPage, hasPreviousPage}`.

Rules (all verified):

- **Omitting `limit` defaults to 20** → any call that doesn't paginate silently shows only the first
  20 records. This broke the admin lists until they were wired.
- `limit` max is **50** → `400 ["limit must not be greater than 50"]`.
- `page` starts at **1** → `400 ["page must not be less than 1"]`; a page past the end returns
  `items: []` with `hasNextPage: false`.
- `search` + pagination compose (`search=محمد` → `total: 43`).
- The courses endpoints take **no status parameter**, so one paginated pool contains all statuses and
  any status tabs must classify what has arrived.
- `GET /admins/search/courses` is **still unpaged** (returns everything in `items`).
- Pagination params also exist on `/teachers/me/courses/active|expired`, `/teachers/me/withdrawals`,
  `/teachers/{id}/withdrawals`, and `/dashboard/*` (student-scoped) — those are what the student app uses.
- `GET /admins/teachers/{teacherId}/courses` gained `status` (`active | expired`) on the same date.

## Response shapes that a previous guess got wrong (verified 2026-09-21)

- `GET /admins/search/courses` → `{tabs: {activeCourses, …}, filters: {...}, items: [...]}`.
  The list is under **`items`**. Omitting `status` means **`active`**, not "all". **REJECTED courses
  are in the `deleted` bucket**. Items are flat (`teacherName`, `subjectOrProgramName`, `relatedTo`)
  with no image or price.
- `GET /uploads/videos/{id}/resolutions` → list under **`mp4Resolutions`** (`{resolution, path, sizeBytes}`).
  Stream URL = `video.videoUrl` (ends in `play_`) + resolution (e.g. `240p`) + `.mp4` — returns
  `200 video/mp4`.
- `GET /advertisements?universityId=…` **excludes global ads** (`universityId: null`). Fetch unfiltered
  and keep global + current-university ads.
- `PATCH /advertisements/{id}` takes every create field (`universityId`, `collegeId`, `departmentId`,
  `title`, `imageUrl`, `fullScreen_imageUrl`, `videoUrl`, `helperLink`). Since 2026-10-24 (branch
  `fix/ads-edit-all-fields`) **`null` clears** the media fields too; the admin sends all of them, so an
  image ad turned into a video ad loses its images. The student app shows `videoUrl` first on the banner
  and `fullScreen_imageUrl` first in the preview, so a stale field would win.
- `GET /admins/users-directory?type=student&search=` matches **name, university number and phone**
  (swagger says name only). For `type=teacher` it matches **name only** — the backend cannot search
  teachers by phone. There is **no parameter to choose the search field**; isolating one is client-side
  (university numbers come from `/admins/search/students`, which never returns phone).
  Student items: `{id, name, status, university: {id, name}, department}`.
  Teacher items: `{id, name, image, status, likesCount, isLikedByMe, coursesCount}`.
- `GET /courses/{id}` is the **only** source of raw `categoryId`, `courseDiscountPercentage`
  (numbers arrive as strings), `videosCount`, `filesCount` and `lectures[]`.
- Course details for admins need **two** calls merged: `/courses/{id}/admin-details/info`
  (college/department/subject/rating) and the public `/courses/{id}/details` (image, prices, counters,
  expiry, lectures).
- `GET /app-description` is **public** (no auth). Both apps' About screens read it; the student app
  falls back to its hardcoded text when it's empty.
- `GET /teachers/me/affiliations` called **as an admin returns all** affiliations
  (`teacherId/collegeId/departmentId`) — use it for college/department teacher filters.
  `/admins/getTeachersByCollageID` is unreliable (returned 1 of 8).
- Course list endpoints return **`college: null`** even for courses that belong to one, so filtering
  courses by college goes through `/admins/getSubjectsByCollageId` (or
  `/admins/getSubjectsByDeptarmentId`) and matching `subject.id`.
- `/admins/teachers/{id}/profile` courses have **no `imageUrl`**; `/admins/teachers/{id}/courses`
  returns full records.
- `/teachers/{id}/allowed-subjects` sends `season: {name}` and a root `academicYear: {name}` —
  **not** `seasonName`/`collegeYear`. Parsers must accept both shapes.
- Dashboard course items include `{id, name, description, imageUrl, price (string), duration (seconds),
  isCompleted, status, expiresAt, season{id,name,number}, year{id,name,number},
  academicYear{id,yearName,yearNumber}, teacher{id,name,image,telegramUrl,instagramUrl},
  subject{id,name}, category, college: null, department: null, studentsCount}`.

## Domain rules worth remembering

- **Course status enum: `PENDING | APPROVED | REJECTED`.** "Expired" is **not** a status — it is derived
  from `expiresAt`. The admin UI's four tabs map to: active = APPROVED & not expired, expired = APPROVED
  & past `expiresAt`, pending = PENDING, rejected = REJECTED (`status=deleted` in the search endpoint).
- Account status values seen: `active`, `pending`, `banned`/`suspended`, `deleted`.
- `duration` is **seconds**, computed from the course's videos; it is `0` for courses with no video.
- Academic tree: university → college (`/academics/colleges`) → department (`/academics/departments`) →
  year (`/academics/years`, `/academics/academic-years`) + season (`/academics/seasons`) →
  subject (`/academics/subjects`) or program (`/admins/getProgramsByCollageId`).
- Creating/publishing a course for a teacher requires the teacher to have **permission (affiliation)
  on that subject/program**, otherwise `403 «لا توجد صلاحية لهذا المدرس على المادة/البرنامج»`.
- Resumable video upload is TUS: `/uploads/videos/tus/init` → `/uploads/videos/tus/complete`.

## Probing recipes

Swagger diff (which params exist, what changed):

```bash
curl -s https://coursay.duckdns.org/api-json -o api.json
# then inspect paths[...].get.parameters with python/jq
```

One authenticated GET (from the user's PowerShell):

```powershell
Invoke-RestMethod -Uri "https://coursay.duckdns.org/admins/users-directory?type=student&page=1&limit=5" -Headers @{Authorization="Bearer $token"} | ConvertTo-Json -Depth 6
```

Driving the app's **real** data sources against the server (throwaway test, delete afterwards):

```dart
// test/zz_tmp_probe_test.dart
final client = Client()..dio.options.headers["Authorization"] = "Bearer $token";
final ds = CoursesRemoteDataSourceImp(client);
final page1 = await ds.getAllCourses(universityId, true, page: 1, limit: 5);
print("${page1.items.length} / ${page1.total} hasMore=${page1.hasMore}");
```

This is the cheapest way to catch a parser that silently returns an empty list — several "the screen is
empty" bugs in the admin app were exactly that.
