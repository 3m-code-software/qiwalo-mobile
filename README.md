# قيوالو — تطبيق أندرويد (Flutter)

تطبيق أندرويد RTL لقيوالو، بيتكلّم مع Next.js BFF في مستودع الويب بدل ما يتصل بـ Supabase مباشرة. الويب لسه في `K:\qiwalo\qiwalo-fresh` / <https://github.com/3m-code-software/qiwalo>.

## الحالة الحالية

- **متصل فعلياً بالخادم:** تفاصيل الوحدة، معرض الصور، التوافر، تسعير الحجز، تأكيد الحجز، رقم المرجع، والبحث برقم الحجز.
- **واجهة جاهزة لكنها محلية:** الدخول، التسجيل، تفعيل تليجرام، استعادة الباسورد، الرئيسية/البحث، الفلاتر، المفضلة، الملف الشخصي، المساعدة، وتفاصيل الحجز المعاينة.
- **مؤجّل بطلب صريح:** قائمة نتائج البحث، إشعارات Push، التوقيع Release، شاشات المالك/السائق الثماني، الخريطة.

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

السعر والقواعد والتحقق النهائي كلها على الخادم في `lib/booking-service.ts` بمستودع الويب؛ التطبيق ما بيحسبش أسعار.

## الإصدارات

كل تحديث بياخد GitHub Release لوحده في هذا المستودع، مع APK ولقطات Pixel 7. أحدث إصدار: `mobile-v1.0.0`.
