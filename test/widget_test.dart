import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qiwalo_app/api/api_client.dart';
import 'package:qiwalo_app/api/role_repository.dart';
import 'package:qiwalo_app/api/unit_repository.dart';
import 'package:qiwalo_app/main.dart';
import 'package:qiwalo_app/screens/design_index.dart';
import 'package:qiwalo_app/owner_driver_data.dart';
import 'package:qiwalo_app/screens/discover.dart';
import 'package:qiwalo_app/screens/owner_driver.dart';

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
      ],
      'availability': [
        {'date': '2026-11-26', 'isBlocked': false, 'priceOverride': null},
        {'date': '2026-11-27', 'isBlocked': true, 'priceOverride': 1500},
      ],
      'priceRules': <dynamic>[],
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
  });

  testWidgets('فهرس المراجعة لسه بيعرض الشاشات الأربعة والعشرين', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DesignIndexScreen()));
    expect(find.text('كل الشاشات · ٢٤'), findsOneWidget);
    expect(find.text('١٦ · المساعدة والشروط'), findsOneWidget);
    expect(find.text('١٧ · لوحة المالك'), findsOneWidget);
    expect(find.text('٢٤ · المركبة والملف'), findsOneWidget);
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
    expect(find.text('مضيف الاختبار'), findsOneWidget);
    expect(find.textContaining('وصف حقيقي قادم من BFF'), findsOneWidget);
    expect(find.text('إطلالة على النيل'), findsOneWidget);
    expect(find.text('ضيف حقيقي'), findsOneWidget);
    expect(find.text('تحويل بنكي أو كاش عند الوصول'), findsOneWidget);
    expect(find.text('١٬٢٠٠ ج.م / ليلة'), findsOneWidget);
    expect(find.text('معاينة محلية'), findsNothing);
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
}
