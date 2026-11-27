import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qiwalo_app/api/api_client.dart';
import 'package:qiwalo_app/api/booking_repository.dart';
import 'package:qiwalo_app/api/favorite_repository.dart';
import 'package:qiwalo_app/api/role_repository.dart';
import 'package:qiwalo_app/api/unit_repository.dart';
import 'package:qiwalo_app/main.dart';
import 'package:qiwalo_app/screens/account.dart';
import 'package:qiwalo_app/screens/auth.dart';
import 'package:qiwalo_app/screens/design_index.dart';
import 'package:qiwalo_app/owner_driver_data.dart';
import 'package:qiwalo_app/screens/discover.dart';
import 'package:qiwalo_app/screens/owner_driver.dart';

/// بديل في الذاكرة عشان اختبارات الواجهة ما تعتمدش على secure storage.
class _MemoryFavorites extends FavoriteRepository {
  _MemoryFavorites([List<String> slugs = const <String>[]])
      : _slugs = List<String>.from(slugs);

  final List<String> _slugs;

  @override
  Future<List<String>> load() async => List<String>.unmodifiable(_slugs);

  @override
  Future<bool> toggle(String slug) async {
    final clean = slug.trim();
    if (clean.isEmpty) return false;
    final added = !_slugs.contains(clean);
    if (added) {
      _slugs.add(clean);
    } else {
      _slugs.remove(clean);
    }
    return added;
  }

  @override
  Future<void> remove(String slug) async {
    _slugs.remove(slug);
  }
}

Map<String, dynamic> _apiBody() => {
      'ok': true,
      'unit': {
        'slug': 'test-slug',
        'name': 'وحدة الاختبار',
        'host': 'مضيف الاختبار',
        'typeAr': 'شقة',
        'cityAr': 'الأقصر',
        'address': 'الكورنيش',
        'description': 'وصف حقيقي قادم من BFF.',
        'images': <String>[],
        'amenities': ['واي فاي', 'إطلالة على النيل'],
        'maxGuests': 4,
        'bedrooms': 2,
        'bathrooms': 1,
        'areaSqm': 95,
        'basePrice': 1200,
        'currency': 'EGP',
        'rating': 4.7,
        'reviewCount': 12,
        'cancellation': 'إلغاء مجاني قبل الوصول بـ 48 ساعة',
        'houseRules': 'لا تدخين داخل الوحدة',
        'lat': 25.6,
        'lng': 32.6,
      },
      'reviews': [
        {
          'rating': 5,
          'comment': 'إقامة مريحة جداً',
          'guestName': 'ضيف حقيقي',
          'createdAt': '2026-11-20T10:00:00.000Z',
          'ownerReply': 'شكراً لك',
        },
        {'rating': 4, 'comment': 'تقييم ثانٍ', 'guestName': 'ضيف ثانٍ', 'createdAt': '2026-11-18T10:00:00.000Z'},
        {'rating': 5, 'comment': 'تقييم ثالث', 'guestName': 'ضيف ثالث', 'createdAt': '2026-11-17T10:00:00.000Z'},
        {'rating': 3, 'comment': 'تقييم رابع', 'guestName': 'ضيف رابع', 'createdAt': '2026-11-16T10:00:00.000Z'},
      ],
      'availability': [
        {'date': '2026-11-26', 'isBlocked': false, 'priceOverride': null},
        {'date': '2026-11-27', 'isBlocked': true, 'priceOverride': 1500},
      ],
      'priceRules': <dynamic>[],
      'addOns': [
        {
          'id': 'pk-test',
          'kind': 'PACKAGE',
          'label': 'باقة الاختبار',
          'subtitle': 'إقامة + سفاري + نقل',
          'price': 1900,
          'priceUnit': 'night',
          'capacity': 4,
        },
      ],
      'pagePath': '/stay/test-slug',
      'support': {
        'phone': '01066094050',
        'whatsapp': 'https://wa.me/201066094050',
        'telegram': 'https://t.me/+201066094050',
      },
      'paymentCopy': 'تحويل بنكي أو كاش عند الوصول',
    };

void main() {
  testWidgets('شاشة الترحيب هي أول شاشة عند فتح التطبيق', (tester) async {
    await tester.pumpWidget(const QiwaloApp());
    expect(find.text('إقامتك وتجاربك في الأقصر وأسوان'), findsOneWidget);
    expect(find.text('ابدأ الآن'), findsOneWidget);
    expect(find.text('عندي حساب · دخول'), findsOneWidget);
    expect(find.text('معاينة كل الشاشات'), findsOneWidget);
    expect(find.text('كل الشاشات · ٢٤'), findsNothing);

    // خلفية الصورة لازم تتحرك ببطء لعدة إطارات من غير ما ترفع استثناء.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('قيوالو'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('صورة النيل'), findsOneWidget);
  });

  testWidgets('فهرس المراجعة بيعرض الشاشات الست والعشرين', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DesignIndexScreen()));
    expect(find.text('كل الشاشات · ٢٦'), findsOneWidget);
    expect(find.text('٨ · خريطة الوحدة'), findsOneWidget);
    expect(find.text('١٧ · المساعدة والشروط'), findsOneWidget);
    expect(find.text('١٨ · لوحة المالك'), findsOneWidget);
    expect(find.text('٢٥ · المركبة والملف'), findsOneWidget);
    expect(find.text('٢٦ · التواصل الداخلي'), findsOneWidget);
  });

  testWidgets('ضغط تواصل في الترحيب يفتح صفحة التواصل الداخلي', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const QiwaloApp());
    await tester.tap(find.text('تواصل'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('تواصل معنا'), findsOneWidget);
    expect(find.text('فريق قيوالو جاهز للمساعدة'), findsOneWidget);
    expect(find.text('اكتب رسالتك'), findsOneWidget);
    expect(find.text('إرسال عبر واتساب'), findsOneWidget);
    expect(find.text('إرسال عبر تليجرام'), findsOneWidget);
  });

  testWidgets('إنشاء الحساب: كود الدولة والاسم والباسورد والشروط داخل الشاشة', (tester) async {
    final previousLocale = tester.binding.platformDispatcher.locale;
    tester.binding.platformDispatcher.localeTestValue = const Locale('ar', 'EG');
    addTearDown(() =>
        tester.binding.platformDispatcher.localeTestValue = previousLocale);
    await tester.binding.setSurfaceSize(const Size(412, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    expect(find.text('مصر +20'), findsOneWidget);
    expect(
      find.text('اكتب الاسم كما يظهر في بطاقة الهوية أو جواز السفر'),
      findsOneWidget,
    );
    expect(find.textContaining('قوة كلمة المرور: اكتب كلمة مرور'), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    final passwordField = find.ancestor(
      of: find.text('الباسورد'),
      matching: find.byType(TextField),
    ).first;
    await tester.enterText(passwordField, 'Qiwalo123!');
    await tester.pump();
    expect(find.textContaining('قوة كلمة المرور: قوية'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.text('أوافق على الشروط والأحكام وسياسة الخصوصية'));
    await tester.pumpAndSettle();
    expect(find.text('١ · الحجز والتأكيد'), findsOneWidget);
    expect(find.text('إغلاق'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsWidgets);
  });

  testWidgets('تسجيل الدخول يقبل الإيميل أو التليفون والباسورد إظهار وقوة', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('الإيميل أو رقم التليفون'), findsOneWidget);
    expect(find.text('استخدم الإيميل أو رقم التليفون اللي سجّلت بيه'), findsOneWidget);

    final identifier = find.ancestor(
      of: find.text('الإيميل أو رقم التليفون'),
      matching: find.byType(TextField),
    ).first;
    await tester.enterText(identifier, 'owner@qiwalo.test');
    await tester.pump();
    expect(find.text('تم التعرف على إيميل'), findsOneWidget);

    await tester.enterText(identifier, '01066094050');
    await tester.pump();
    expect(find.text('تم التعرف على رقم تليفون'), findsOneWidget);

    final passwordField = find.ancestor(
      of: find.text('الباسورد'),
      matching: find.byType(TextField),
    ).first;
    await tester.enterText(passwordField, 'Qiwalo123!');
    await tester.pump();
    expect(find.textContaining('قوة كلمة المرور: قوية'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('الاتجاه RTL مفروض على كل التطبيق', (tester) async {
    await tester.pumpWidget(const QiwaloApp());
    final direction = Directionality.of(tester.element(find.text('قيوالو')));
    expect(direction, TextDirection.rtl);
  });

  testWidgets('شاشات المالك والسائق بتفتح بنصوص عربية', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OwnerDashboardScreen(snapshot: RoleSnapshot.mock()),
    ));
    expect(find.text('لوحة المالك'), findsWidgets);
    expect(find.text('وحدات منشورة'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: DriverTripsScreen(snapshot: RoleSnapshot.mock()),
    ));
    expect(find.text('الرحلات المتاحة'), findsWidgets);
    expect(find.text(driverTrips.first.fare), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: DriverTripDetailScreen(trip: driverTrips.first),
    ));
    expect(find.text('تفاصيل الرحلة'), findsWidgets);
    expect(find.textContaining(driverTrips.first.to), findsOneWidget);
  });

  testWidgets('صفحة الوحدة تعرض بيانات BFF بدل العناصر الفارغة', (tester) async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/mobile/units/test-slug');
      return http.Response(
        jsonEncode(_apiBody()),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = UnitRepository(
      client: ApiClient(httpClient: client),
      useMock: false,
    );

    await tester.pumpWidget(MaterialApp(
      home: UnitScreen(slug: 'test-slug', repository: repository),
    ));
    await tester.pumpAndSettle();

    expect(find.text('وحدة الاختبار'), findsOneWidget);
    expect(find.text('الأقصر · شقة'), findsOneWidget);
    expect(find.text('الكورنيش'), findsWidgets);
    expect(find.text('مضيف الاختبار'), findsOneWidget);
    expect(find.textContaining('وصف حقيقي قادم من BFF'), findsOneWidget);
    expect(find.text('إطلالة على النيل'), findsOneWidget);
    expect(find.text('ضيف حقيقي'), findsOneWidget);
    expect(find.text('تحويل بنكي أو كاش عند الوصول'), findsOneWidget);
    expect(find.text('١٬٢٠٠ ج.م / ليلة'), findsOneWidget);
    expect(find.text('الموقع'), findsOneWidget);
    expect(find.text('افتح في خرائط جوجل'), findsOneWidget);
    expect(find.text('باقة الاختبار'), findsOneWidget);
    expect(find.text('معاينة محلية'), findsNothing);

    expect(find.text('تقييم رابع'), findsNothing);
    final showAll = find.text('عرض كل التقييمات (٤)');
    await tester.ensureVisible(showAll);
    await tester.pumpAndSettle();
    await tester.tap(showAll);
    await tester.pumpAndSettle();
    expect(find.text('تقييم رابع'), findsOneWidget);
  });

  test('فشل الشبكة لا يفرغ صفحة الوحدة ويرجع نسخة محلية معلَّمة', () async {
    final repository = UnitRepository(
      client: ApiClient(
        httpClient: MockClient((_) async => http.Response('not-json', 200)),
      ),
      useMock: false,
    );

    final unit = await repository.fetchUnit('any-slug');
    expect(unit.fromMock, isTrue);
    expect(unit.name, 'دار المدينة بإطلالة على النيل');
    expect(unit.paymentCopy, 'تحويل بنكي أو كاش عند الوصول');
  });

  testWidgets('المفضلة بتتحفظ بزر القلب داخل صفحة الوحدة', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: UnitScreen(
        repository: const UnitRepository(useMock: true),
        favorites: _MemoryFavorites(),
      ),
    ));
    await tester.pumpAndSettle();

    final heart = find.byTooltip('إضافة للمفضلة');
    expect(heart, findsOneWidget);
    await tester.tap(heart);
    await tester.pumpAndSettle();
    expect(find.byTooltip('إزالة من المفضلة'), findsOneWidget);
    expect(find.text('تمت الإضافة إلى المفضلة'), findsOneWidget);
  });

  testWidgets('شاشة المفضلة بتقرأ الوحدات المحفوظة وتسمح بإزالتها', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FavoritesScreen(
        favorites: _MemoryFavorites(<String>['aswan-nubian-house']),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('نزل النخيل'), findsOneWidget);
    expect(find.text('أسوان · نزل · ٣ غرف'), findsOneWidget);

    await tester.tap(find.byTooltip('إزالة من المفضلة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('لسه ما حفظت أي وحدة'), findsOneWidget);
  });

  testWidgets('اختيار الإضافة والتقويم بيحدّث مسودة الحجز', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: UnitScreen(repository: const UnitRepository(useMock: true)),
    ));
    await tester.pumpAndSettle();

    final safari = find.text('سفاري جبل السلسلة عند الغروب');
    await tester.ensureVisible(safari);
    await tester.pumpAndSettle();
    await tester.tap(safari);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);

    await tester.ensureVisible(find.text('عرض كل التواريخ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض كل التواريخ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('٢٩'));
    await tester.pumpAndSettle();
    expect(find.textContaining('وصول ٢٩/١١/٢٠٢٦'), findsOneWidget);

    await tester.tap(find.textContaining('تم · وصول'));
    await tester.pumpAndSettle();
    expect(find.text('٢٩/١١/٢٠٢٦'), findsWidgets);
  });

  testWidgets('صفوف الدعم تفتح الروابط الخارجية', (tester) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(MaterialApp(
      home: UnitScreen(repository: const UnitRepository(useMock: true)),
    ));
    await tester.pumpAndSettle();

    final phoneIcon = find.byIcon(Icons.call_outlined);
    await tester.ensureVisible(phoneIcon);
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: phoneIcon, matching: find.byType(ListTile)),
    );
    await tester.pumpAndSettle();

    expect(
      calls.any((call) =>
          call.method == 'canLaunch' &&
          (call.arguments as Map)['url'] == 'tel:01066094050'),
      isTrue,
    );
    expect(
      calls.any((call) =>
          call.method == 'launch' &&
          (call.arguments as Map)['url'] == 'tel:01066094050'),
      isTrue,
    );
  });

  test('معرّفات الإضافات تُرسل وحدها للـ quote والتأكيد', () async {
    final bodies = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      bodies.add(body);
      const headers = {'content-type': 'application/json'};
      if (request.url.path == '/api/mobile/bookings/quote') {
        return http.Response(
          jsonEncode({
            'ok': true,
            'quote': {
              'nights': 3,
              'nightly': <dynamic>[],
              'subtotal': 0,
              'serviceFee': 0,
              'commission': 0,
              'total': 0,
              'addOns': <dynamic>[],
              'grandTotal': 0,
              'paymentCopy': 'تحويل بنكي أو كاش عند الوصول',
            },
          }),
          200,
          headers: headers,
        );
      }
      return http.Response(
        jsonEncode({
          'ok': true,
          'booking': {
            'reference': 'QW-TEST',
            'propertyName': 'وحدة الاختبار',
            'cityAr': 'الأقصر',
            'checkIn': '2026-11-29',
            'checkOut': '2026-12-02',
            'nights': 3,
            'guests': 2,
            'status': 'CONFIRMED',
            'paymentStatus': 'PENDING',
            'paymentMethod': 'CASH',
            'total': 0,
            'createdAt': '2026-11-27T00:00:00.000Z',
            'paymentCopy': 'تحويل بنكي أو كاش عند الوصول',
            'support': {
              'phone': '01066094050',
              'whatsapp': 'https://wa.me/201066094050',
              'telegram': 'https://t.me/+201066094050',
            },
            'pagePath': '/booking/QW-TEST',
          },
        }),
        200,
        headers: headers,
      );
    });
    final repository = BookingRepository(
      client: ApiClient(httpClient: client),
      useMock: false,
    );
    final draft = BookingDraft(
      slug: 'test-slug',
      unitName: 'وحدة الاختبار',
      cityAr: 'الأقصر',
      checkIn: '2026-11-29',
      checkOut: '2026-12-02',
      packageId: 'pk-test',
    );

    await repository.quote(
      slug: draft.slug,
      checkIn: draft.checkIn,
      checkOut: draft.checkOut,
      guests: draft.guests,
      packageId: draft.packageId,
    );
    await repository.confirm(
      draft: draft,
      fullName: 'أحمد محمد',
      email: 'guest@qiwalo.test',
      phone: '01066094050',
      nationality: 'مصرية',
      paymentMethod: 'CASH',
      idempotencyKey: 'test-key',
    );

    expect(bodies.first['packageId'], 'pk-test');
    expect(bodies.first.containsKey('price'), isFalse);
    expect(bodies.last['packageId'], 'pk-test');
    expect(bodies.last.containsKey('total'), isFalse);
  });
}
