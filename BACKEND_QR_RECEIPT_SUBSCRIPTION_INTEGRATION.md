# تكامل الاشتراك عبر QR والإيصال

هذا المستند هو عقد التكامل المطلوب بين تطبيق الطالب والباك إند. تطبيق Flutter يرسل الطلبات أدناه الآن؛ إلى أن تُنفّذ الواجهات سيظهر للمستخدم خطأ API واضح ويمكنه إعادة المحاولة.

## الهدف ودورة الحالة

`اهتماماتي` ليست قيمة جديدة في `CourseStatus`. هي علاقة مستقلة بين الطالب والكورس تستخدم لحفظ نية الدفع والعودة إليها لاحقًا:

```text
عرض QR ── لقطة شاشة/حفظ يدوي ──> StudentCourseInterest (بانتظار الإيصال)
                                        │
                                        └── رفع الإيصال ──> SubscriptionRequest(PENDING)
                                                                    │
                                      ┌─────────────────────────────┴────────────────────────────┐
                                      ▼                                                          ▼
                                APPROVED                                                   REJECTED
                         حذف الاهتمام ذريًا + اشتراك                         حذف الاهتمام ذريًا + سبب الرفض
```

لا يجوز للطالب حذف اهتمام مرتبط بطلب `PENDING`. بعد القبول يظهر الكورس في الاشتراكات الفعالة الحالية؛ وبعد الرفض يعود كورسًا متاحًا ويمكن بدء محاولة جديدة من QR.

## تغييرات نموذج البيانات (Prisma مقترح)

```prisma
enum CourseInterestSource {
  QR_SCREENSHOT
  MANUAL
}

model Course {
  id           String   @id @default(cuid())
  // الحقول الحالية …
  paymentQrUrl String?
  interests    StudentCourseInterest[]
}

model StudentCourseInterest {
  id        String               @id @default(cuid())
  studentId String
  courseId  String
  source    CourseInterestSource
  createdAt DateTime             @default(now())
  updatedAt DateTime             @updatedAt

  student   Student @relation(fields: [studentId], references: [id], onDelete: Cascade)
  course    Course  @relation(fields: [courseId], references: [id], onDelete: Cascade)

  @@unique([studentId, courseId])
  @@index([studentId, createdAt])
}
```

لا تُعدّل enum `CourseStatus` الحالية (`PENDING`, `APPROVED`, `REJECTED`). يبقى `SubscriptionRequest` مصدر حالة طلب الاشتراك والإدارة.

## عرض QR في تفاصيل الكورس

أضف الحقل الاختياري `paymentQrUrl` إلى كائن `course` في:

```http
GET /courses/:id/details
```

مثال مختصر:

```json
{
  "course": {
    "id": "clx-course",
    "name": "الخوارزميات",
    "basePrice": 125000,
    "discountedPrice": 100000,
    "paymentQrUrl": "https://cdn.example.com/payment-qr/clx-course.webp"
  }
}
```

واجهة الإدارة، بصلاحية `ADMIN` أو الصلاحية الحالية لإدارة الكورس:

```http
PATCH /courses/:id/payment-qr
Content-Type: multipart/form-data

file: <JPG | PNG | WebP، بحد أقصى 5MB>
```

```json
{ "paymentQrUrl": "https://cdn.example.com/payment-qr/clx-course.webp" }
```

```http
DELETE /courses/:id/payment-qr
```

يعيد الحذف `204` أو `{ "paymentQrUrl": null }`. يجب إزالة الملف السابق من التخزين بأمان بعد نجاح الاستبدال أو الحذف.

## واجهات الاهتمامات

كل الواجهات التالية تتطلب الطالب المسجّل، وتستخرج `studentId` من JWT فقط، وليس من جسم الطلب.

### حفظ اهتمام (idempotent)

```http
POST /students/me/course-interests/:courseId
Content-Type: application/json

{ "source": "QR_SCREENSHOT" }
```

القيم المقبولة: `QR_SCREENSHOT` و`MANUAL`. عند تكرار الطلب لنفس الطالب والكورس أعد السجل القائم (200 أو 201) ولا تنشئ صفًا ثانيًا.

```json
{
  "interest": {
    "id": "interest-1",
    "courseId": "clx-course",
    "source": "QR_SCREENSHOT",
    "createdAt": "2026-09-30T10:00:00.000Z",
    "course": {
      "id": "clx-course",
      "name": "الخوارزميات",
      "imageUrl": "https://…",
      "basePrice": 125000,
      "discountedPrice": 100000,
      "paymentQrUrl": "https://…"
    },
    "pendingRequest": null
  }
}
```

التحقق قبل upsert: ارفض الاهتمام بكورس مجاني أو منتهٍ أو غير معتمد أو مخفي أو بلا `paymentQrUrl` أو يملك الطالب اشتراكًا فعالًا به. لا تعتمد على التحقق من الواجهة فقط.

### قائمة الاهتمامات

```http
GET /students/me/course-interests
```

```json
{
  "interests": [
    {
      "id": "interest-1",
      "courseId": "clx-course",
      "source": "MANUAL",
      "createdAt": "2026-09-30T10:00:00.000Z",
      "course": { "id": "clx-course", "name": "الخوارزميات", "imageUrl": "https://…", "paymentQrUrl": "https://…" },
      "pendingRequest": {
        "id": "request-1",
        "status": "PENDING",
        "receiptUrl": "https://…",
        "adminNote": null,
        "createdAt": "2026-09-30T10:05:00.000Z"
      }
    }
  ]
}
```

رتّب النتائج بالأحدث أولًا. لا تُرجع طلبًا غير معلق ضمن `pendingRequest`؛ السجل يحذف عند القرار النهائي.

### إزالة اهتمام قبل رفع الإيصال

```http
DELETE /students/me/course-interests/:courseId
```

اسمح به فقط عند عدم وجود طلب اشتراك معلق لهذا الطالب والكورس. يرد بـ `204` (أو `200`). عند وجود `PENDING` أعد `409 INTEREST_HAS_PENDING_REQUEST`.

## رفع الإيصال

العميل ينفذ مباشرة:

```http
POST /financials/subscription-requests/with-receipt
Content-Type: multipart/form-data

courseId: clx-course
file: <receipt.jpg>
note: نص اختياري حتى 400 حرف
```

الاستجابة المقترحة:

```json
{
  "subscriptionRequest": {
    "id": "request-1",
    "status": "PENDING",
    "receiptUrl": "https://cdn.example.com/receipts/request-1.webp",
    "adminNote": null,
    "createdAt": "2026-09-30T10:05:00.000Z"
  }
}
```

يجب أن يظل `StudentCourseInterest` موجودًا بعد إنشاء الطلب. ارفض تكرار الطلب المعلق لنفس `(studentId, courseId)` بـ `409 SUBSCRIPTION_REQUEST_ALREADY_PENDING`؛ التطبيق يمنع النقر المتكرر لكنه لا يغني عن هذا القيد على الخادم.

### تحقق الملف

- الحد: `5 * 1024 * 1024` بايت.
- الصيغ: JPEG/JPG وPNG وWebP فقط (لا يقبل التطبيق PDF لهذه الميزة).
- تحقّق من magic bytes وMIME الفعلي، لا من الامتداد أو `Content-Type` فقط.
- غيّر اسم الملف عشوائيًا، لا تستخدم الاسم القادم من العميل، وخزّنه خارج أي مسار قابل للتنفيذ.
- يمكن فحص أبعاد معقولة وإعادة ترميز الصورة قبل النشر لخفض مخاطر المحتوى الضار.

## قرار الإدارة والذرية

داخل transaction واحدة عند قرار الإدارة على طلب معلق:

1. تحقق أن القرار الوحيد التالي هو `APPROVED` أو `REJECTED`.
2. حدّث `SubscriptionRequest` و`adminNote`.
3. عند `APPROVED` أنشئ/فعّل الاشتراك الحالي وفق المنطق القائم.
4. احذف `StudentCourseInterest` المطابق للطالب والكورس في الحالتين.
5. أرسل Firebase بعد commit، وليس قبله.

عند التنافس بين قرارين أو بين قرار ورفع جديد استخدم transaction وعزلًا مناسبًا/قيدًا فريدًا، بحيث لا ينتج اشتراكان أو طلبان معلقان.

## إشعار Firebase المطلوب

بعد قرار الإدارة أرسل data payload (إضافة إلى notification المرئية عند الحاجة):

```json
{
  "type": "SUBSCRIPTION_REQUEST_REVIEWED",
  "courseId": "clx-course",
  "requestId": "request-1",
  "status": "APPROVED",
  "adminNote": "تم قبول الإيصال"
}
```

يستقبل التطبيق هذا الحدث ويعيد تحميل قائمة الاهتمامات والاشتراكات الفعالة والمنتهية. عند `REJECTED` اعرض `adminNote` في نص الإشعار المرئي إن وُجد.

## الأخطاء المتفق عليها

| HTTP | code | المعنى |
| --- | --- | --- |
| 400 | `INVALID_RECEIPT_FILE` | صيغة، بصمة، حجم، أو حقل multipart غير صالح |
| 400 | `COURSE_PAYMENT_QR_MISSING` | لا يوجد QR قابل للدفع للكورس |
| 401 | `UNAUTHENTICATED` | لا توجد جلسة طالب صالحة |
| 403 | `COURSE_NOT_AVAILABLE_FOR_SUBSCRIPTION` | مجاني/منتهي/غير معتمد/مخفي أو صلاحية غير مناسبة |
| 404 | `COURSE_NOT_FOUND` | الكورس غير موجود أو غير مرئي للطالب |
| 409 | `ACTIVE_SUBSCRIPTION_EXISTS` | الطالب مشترك فعليًا |
| 409 | `SUBSCRIPTION_REQUEST_ALREADY_PENDING` | يوجد إيصال قيد المراجعة |
| 409 | `INTEREST_HAS_PENDING_REQUEST` | محاولة حذف اهتمام مربوط بطلب معلق |

استخدم شكل الخطأ الحالي للمشروع، على الأقل: `{ "message": "…", "code": "…" }`.

## ترتيب التنفيذ والتوافق

1. أضف migration للـ enum و`StudentCourseInterest` و`Course.paymentQrUrl` ثم نفّذ backfill = `null` للـ QR.
2. نفّذ رفع/حذف QR الإداري وأضف `paymentQrUrl` إلى course details دون كسر المستهلكين القدامى لأنه اختياري.
3. نفّذ GET/POST/DELETE للاهتمامات مع الفهارس والقيود السابقة.
4. عدّل endpoint الإيصال الموجود ليحافظ على الاهتمام، ثم احذف الاهتمام ذرّيًا داخل مسار قرار الإدارة.
5. أرسل إشعار Firebase واختبره في foreground/background/terminated.
6. أضف اختبارات: idempotency، منع طلبين معلقين، صلاحيات طالب/إدارة، تحقق magic bytes، وحذف الاهتمام عند ACCEPT/REJECT.

الواجهات القديمة لمسح كود الاشتراك ونقاط البيع والدعم تبقى كما هي. التطبيق يخفيها افتراضيًا خلف `SubscriptionFeatureFlags.showLegacySubscriptionMethods` ويمكن إعادتها دون تغيير تدفق QR الرئيسي.
