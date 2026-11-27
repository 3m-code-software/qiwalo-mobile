# قيوالو — تطبيق أندرويد (Flutter)

تطبيق أندرويد RTL لقيوالو، بيتكلّم مع Next.js BFF في مستودع الويب بدل ما يتصل بـ Supabase مباشرة. الويب لسه في `K:\qiwalo\qiwalo-fresh` / <https://github.com/3m-code-software/qiwalo>.

## الحالة الحالية

- **متصل فعلياً بالخادم:** تفاصيل الوحدة، معرض الصور، التوافر، تسعير الحجز، تأكيد الحجز، رقم المرجع، والبحث برقم الحجز.
- **واجهة جاهزة لكنها محلية:** الدخول، التسجيل، تفعيل تليجرام، استعادة الباسورد، الرئيسية/البحث، الفلاتر، المفضلة، الملف الشخصي، المساعدة، وتفاصيل الحجز المعاينة.
- **شاشات المالك/السائق الثماني:** لوحة المالك، وحداتي، إضافة/تعديل وحدة، طلبات الحجز، لوحة السائق، الرحلات المتاحة، تفاصيل الرحلة، والمركبة/الملف — مرتبطة بـ BFF الأدوار بعد الدخول بحساب مالك أو سائق. التوكن يُحفظ في مساحة آمنة على الجهاز، والبيانات بتاعة حساب المستخدم فقط. على Mock تظهر نفس الشاشات ببيانات معاينة.
- **مؤجّل بطلب صريح:** قائمة نتائج البحث، إشعارات Push، التوقيع Release، والخريطة.

## التشغيل محلياً

```powershell
flutter pub get
flutter analyze
flutter test

# نسخة للمراجعة بالـ Mock (بدون شبكة)
flutter run --dart-define=USE_MOCK=true

# نسخة تتكلّم مع BFF المنشور
flutter run

# نسخة تتكلّم مع خادم محلي على نفس الشبكة
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:3130
```

## بناء APK

```powershell
flutter build apk --debug
Copy-Item build\app\outputs\flutter-apk\app-debug.apk releases\qiwalo.apk -Force
```

الملف الناتج: `releases/qiwalo.apk` — حزمة `com.qiwalo.app` واسم التطبيق «قيوالو». إرشادات التثبيت في [`docs/INSTALL-ANDROID.md`](docs/INSTALL-ANDROID.md).

## لقطات التصميم

- صفحة المراجعة: [`docs/design/index.html`](docs/design/index.html)
- لقطات Pixel 7: [`docs/design/pixel7/`](docs/design/pixel7/) — متاحة أيضاً كأصول مضغوطة في كل GitHub Release.
- إعادة التوليد: شغّل سيرفر ثابت على `build/web` ثم `node tools/screenshot-design.cjs`.

## الـ BFF المستخدم

| الغرض | المسار |
|---|---|
| تفاصيل وحدة منشورة | `GET /api/mobile/units/[slug]` |
| تسعير قبل الحجز | `POST /api/mobile/bookings/quote` |
| إنشاء حجز مؤكد | `POST /api/mobile/bookings` |
| حالة حجز برقم المرجع | `GET /api/mobile/bookings/[reference]` |
| دخول المالك/السائق | `POST /api/mobile/auth/login` |
| ملخص المالك ووحداته وحجوزاته | `GET /api/mobile/owner/summary`, `GET /api/mobile/owner/properties`, `GET /api/mobile/owner/bookings` |
| حفظ وحدة المالك | `POST /api/mobile/owner/properties`, `PATCH /api/mobile/owner/properties/[id]` |
| ملخص السائق وملفه ومركباته ورحلاته | `GET /api/mobile/driver/summary`, `/profile`, `/vehicles`, `/trips` |
| إيقاف/استئناف استقبال الرحلات | `PATCH /api/mobile/driver/vehicles/[id]/pause` |

السعر والقواعد والتحقق النهائي كلها على الخادم في `lib/booking-service.ts` بمستودع الويب؛ التطبيق ما بيحسبش أسعار. بيانات الأدوار كمان بتتserialise على الخادم في `lib/mobile-role-service.ts`، والتطبيق ما بيرسلش أسعار أو إجماليات من عنده.

## الإصدارات

كل تحديث بياخد GitHub Release لوحده في هذا المستودع، مع APK ولقطات Pixel 7. أحدث إصدار: `mobile-v1.2.3`.

أول ما يفتح التطبيق على أندرويد تظهر **شاشة الترحيب** بخلفية متحركة (توهّج ذهبي، جزيئات صاعدة، وموجتان بيتحركوا ببطء). المميزات التلاتة بقت قابلة للضغط: «ابحث» و«خطّط» للرئيسية، و**«تواصل»** يفتح صفحة تواصل داخلية فيها واتساب/تليجرام/تليفون وصندوق رسالة جاهز للإرسال. ومن شاشة الترحيب رابط «معاينة كل الشاشات» لفهرس المراجعة. بناء الويب بيبدأ بفهرس المراجعة لأنه أداة توليد اللقطات فقط.
