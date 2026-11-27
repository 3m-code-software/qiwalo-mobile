# سياسة الإصدارات — قيوالو أندرويد

كل تحديث في هذا المستودع لازم ياخد **GitHub Release** علني عشان الجمهور يقدر يلاقي النسخة ويتابع التغييرات.

## خطوات كل إصدار

1. التأكد من الفحوصات:
   ```powershell
   flutter analyze
   flutter test
   flutter build apk --debug
   Copy-Item build\app\outputs\flutter-apk\app-debug.apk releases\qiwalo.apk -Force
   ```
2. إعادة توليد لقطات Pixel 7 لو فيه تغيير واجهة.
3. رفع الكود على `main` في `3m-code-software/qiwalo-mobile`.
4. إنشاء Release بtag جديد (`mobile-vX.Y.Z`) وملاحظات عربية مختصرة.
5. إرفاق الأصول دايمًا:
   - `releases/qiwalo.apk`
   - `qiwalo-pixel7-screenshots.zip` (كل لقطات Pixel 7)
   - `filters.png` و`calendar.png` كملفات منفصلة عشان مراجعة الفلاتر والتوافر تكون سهلة.

## الإصدارات الحالية

| الإصدار | التغيير |
|---|---|
| `mobile-v1.0.0` | أول إصدار علني: واجهة RTL كاملة، تفاصيل وحدة من BFF، حجز حقيقي بالتسعير والتأكيد ورقم المرجع، البحث برقم الحجز، ولقطات Pixel 7. |

> التوقيع Release وإشعارات Push وشاشات المالك/السائق لسه مؤجّلة لطلب صريح. الـ APK الحالي debug وموقّع بالتطوير؛ يمكن تثبيته مباشرة على أندرويد ويُوزّع عبر رابط الـ Release.
