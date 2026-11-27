/**
 * يولّد لقطات ثابتة لكل شاشات معاينة التصميم، على مقاسين: ديسكتوب و Pixel 7.
 * التشغيل: node tools/screenshot-design.cjs  (بعد تشغيل سيرفر build/web على المنفذ 3150)
 */
const { chromium } = require('K:/qiwalo/qiwalo-fresh/node_modules/playwright');
const fs = require('node:fs');
const path = require('node:path');

const routes = [
  'design', 'onboarding', 'login', 'signup', 'telegram', 'recovery',
  'home', 'filters', 'unit', 'calendar', 'gallery', 'checkout', 'payment', 'success',
  'bookings', 'booking-detail', 'favorites', 'profile', 'help', 'contact',
  'owner-dashboard', 'owner-units', 'owner-unit-form', 'owner-bookings',
  'driver-dashboard', 'driver-trips', 'driver-trip-detail', 'driver-vehicle',
];

const base = 'http://127.0.0.1:3150/#/';
const outDir = path.join(__dirname, '..', 'docs', 'design');

(async () => {
  const browser = await chromium.launch({ headless: true });
  // الموبايل هو الهدف؛ الديسكتوب مش جزء من المراجعة.
  const viewports = [
    ['pixel7', { width: 412, height: 915 }],
  ];
  for (const [label, viewport] of viewports) {
    const dir = path.join(outDir, label);
    fs.mkdirSync(dir, { recursive: true });
    const context = await browser.newContext({ viewport, locale: 'ar-EG', deviceScaleFactor: 1 });
    const page = await context.newPage();
    // Flutter Web بياخد ثواني أول مرة عشان يعمل bootstrap؛ نستنى قبل أول لقطة.
    await page.goto(base + 'design', { waitUntil: 'networkidle' });
    await page.waitForTimeout(3500);
    for (const route of routes) {
      await page.goto(base + route, { waitUntil: 'networkidle' });
      if (route === 'design') {
        // أول تحميل للـ hash route محتاج وقت أطول في Flutter web؛ إعادة تحميل
        // وانتظار كافي بيمنع اللقطة البيضاء.
        await page.reload({ waitUntil: 'networkidle' });
        await page.waitForTimeout(5000);
      }
      await page.waitForTimeout(800);
      await page.screenshot({ path: path.join(dir, `${route}.png`) });
      process.stdout.write(`${label}/${route}.png\n`);
    }
    await context.close();
  }
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
