# توقيع إصدار قيوالو أندرويد

## الملفات المحلية (لا تُرفع على GitHub)

- `android/app/qiwalo-release.jks` — Keystore containing the release key (`alias: qiwalo`).
- `android/key.properties` — store/key passwords and path. Both are ignored in `android/.gitignore`.
- نسخة احتياطية خارج المستودع: `C:\Users\musta\.qiwalo\qiwalo-release\`.

> لو فقدت الـ Keystore أو كلمات المرور، مش هتقدر توقّع تحديث بنفس هوية التطبيق. احتفظ بالنسخة الاحتياطية في مكان آمن بره الكمبيوتر كمان.

## البناء

```powershell
flutter build apk --release
Copy-Item build\app\outputs\flutter-apk\app-release.apk releases\qiwalo.apk -Force
```

التحقق:

```powershell
$aapt = 'C:\Users\musta\AppData\Local\Android\Sdk\build-tools\35.0.1\aapt.exe'
& $aapt dump badging releases\qiwalo.apk | Select-String '^package:|application-label:'

$apksigner = 'C:\Users\musta\AppData\Local\Android\Sdk\build-tools\35.0.1\apksigner.bat'
& $apksigner verify --verbose --print-certs releases\qiwalo.apk
```

بصمة الشهادة الحالية (SHA-256):

`A6:87:8A:5D:F0:02:43:08:88:BA:1B:BD:30:94:CF:15:16:A1:03:E4:FC:FE:42:EA:AA:9B:A9:B6:5E:62:3B:70`

## إعداد الـ CI

الـ workflow الموجود في `.github/workflows/mobile-ci.yml` بيقرأ الأسرار دي من GitHub Actions secrets:

| Secret | القيمة |
|---|---|
| `KEYSTORE_BASE64` | Keystore مرمّز Base64 (بدون أسطر جديدة). |
| `KEYSTORE_PASSWORD` | كلمة مرور الـ Keystore. |
| `KEY_ALIAS` | `qiwalo`. |
| `KEY_PASSWORD` | كلمة مرور المفتاح. |

توليد الـ Base64 محلياً:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('K:\qiwalo\qiwalo-flutter\android\app\qiwalo-release.jks'))
```

لا تكتب القيم هنا أو في الـ logs.
