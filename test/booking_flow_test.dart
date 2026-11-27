import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qiwalo_app/api/api_client.dart';
import 'package:qiwalo_app/api/booking_repository.dart';
import 'package:qiwalo_app/screens/account.dart';
import 'package:qiwalo_app/screens/booking.dart';

const draft = BookingDraft(
  slug: 'nile-view-dar-al-madina',
  unitName: 'دار المدينة بإطلالة على النيل',
  cityAr: 'الأقصر',
  checkIn: '2026-12-01',
  checkOut: '2026-12-04',
  guests: 2,
  maxGuests: 5,
);

Map<String, dynamic> quoteBody() => {
      'ok': true,
      'quote': {
        'nights': 3,
        'nightly': [
          {'date': '2026-12-01', 'price': 1523, 'ruleName': 'الربيع'},
          {'date': '2026-12-02', 'price': 1523, 'ruleName': 'الربيع'},
          {'date': '2026-12-03', 'price': 1523, 'ruleName': 'الربيع'},
        ],
        'subtotal': 4569,
        'serviceFee': 0,
        'commission': 548,
        'total': 4569,
        'addOns': [],
        'grandTotal': 4569,
        'paymentCopy': 'تحويل بنكي أو كاش عند الوصول',
      },
    };

Map<String, dynamic> bookingBody() => {
      'ok': true,
      'booking': {
        'reference': 'QW-TEST1234-AB12',
        'propertyName': 'دار المدينة بإطلالة على النيل',
        'cityAr': 'الأقصر',
        'checkIn': '2026-12-01',
        'checkOut': '2026-12-04',
        'nights': 3,
        'guests': 2,
        'status': 'CONFIRMED',
        'paymentStatus': 'PENDING',
        'paymentMethod': 'CASH',
        'total': 4569,
        'createdAt': '2026-11-27T10:00:00.000Z',
        'paymentCopy': 'تحويل بنكي أو كاش عند الوصول',
        'support': {
          'phone': '01066094050',
          'whatsapp': 'https://wa.me/201066094050',
          'telegram': 'https://t.me/+201066094050',
        },
        'pagePath': '/booking/QW-TEST1234-AB12',
      },
    };

Future<void> _fillGuest(WidgetTester tester) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'أحمد محمد');
  await tester.enterText(fields.at(1), 'guest@qiwalo.test');
  await tester.enterText(fields.at(2), '01066094051');
  await tester.enterText(fields.at(3), 'مصري');
  await _scrollDown(tester, 900);
  await tester.tap(find.byType(Checkbox));
  await tester.pump();
}

Future<void> _scrollDown(WidgetTester tester, double pixels) async {
  await tester.drag(find.byType(ListView).first, Offset(0, -pixels));
  await tester.pumpAndSettle();
}

Widget _checkoutApp(BookingRepository repository) => MaterialApp(
      home: CheckoutScreen(draft: draft, repository: repository),
      routes: {
        '/success': (context) => BookingSuccessScreen(
              booking: ModalRoute.of(context)!.settings.arguments as MobileBooking,
            ),
      },
    );

void main() {
testWidgets('الحجز يقرأ السعر من BFF ثم يرسل بيانات الضيف فقط ويعرض المرجع الحقيقي',
    (tester) async {
  Map<String, dynamic>? quoteRequest;
  Map<String, dynamic>? bookingRequest;
  String? idempotencyKey;

  final client = MockClient((request) async {
    final decoded = jsonDecode(request.body) as Map<String, dynamic>;
    if (request.url.path == '/api/mobile/bookings/quote') {
      quoteRequest = decoded;
      return http.Response(
        jsonEncode(quoteBody()),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path == '/api/mobile/bookings') {
      bookingRequest = decoded;
      idempotencyKey = request.headers['Idempotency-Key'];
      return http.Response(
        jsonEncode(bookingBody()),
        201,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('not found', 404);
  });
  final repository = BookingRepository(client: ApiClient(httpClient: client));

  await tester.pumpWidget(_checkoutApp(repository));
  await tester.pumpAndSettle();

  expect(quoteRequest, {
    'slug': draft.slug,
    'checkIn': draft.checkIn,
    'checkOut': draft.checkOut,
    'guests': 2,
  });

  await _fillGuest(tester);
  await _scrollDown(tester, 700);
  expect(find.text('٤٬٥٦٩ ج.م'), findsWidgets);
  await tester.tap(find.widgetWithText(ElevatedButton, 'تأكيد الحجز'));
  await tester.pumpAndSettle();

  expect(bookingRequest, isNotNull);
  expect(bookingRequest!['total'], isNull);
  expect(bookingRequest!['subtotal'], isNull);
  expect(bookingRequest!['phone'], '01066094051');
  expect(bookingRequest!['termsAccepted'], isTrue);
  expect(idempotencyKey, matches(r'^qw-[0-9]+-[0-9]+$'));

  expect(find.text('تم تأكيد حجزك!'), findsOneWidget);
  await _scrollDown(tester, 600);
  expect(find.text('QW-TEST1234-AB12'), findsOneWidget);
  expect(find.text('٤٬٥٦٩ ج.م'), findsWidgets);
});

testWidgets('رفض الخادم يظهر رسالته العربية ولا يوهم المستخدم بنجاح الحجز',
    (tester) async {
  final client = MockClient((request) async {
    if (request.url.path == '/api/mobile/bookings/quote') {
      return http.Response(
        jsonEncode(quoteBody()),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response(
      jsonEncode({
        'ok': false,
        'error': 'phone_taken',
        'note': 'رقم التليفون مسجّل بحساب تاني.',
      }),
      409,
      headers: {'content-type': 'application/json'},
    );
  });
  final repository = BookingRepository(client: ApiClient(httpClient: client));

  await tester.pumpWidget(_checkoutApp(repository));
  await tester.pumpAndSettle();
  await _fillGuest(tester);
  await _scrollDown(tester, 700);
  await tester.tap(find.widgetWithText(ElevatedButton, 'تأكيد الحجز'));
  await tester.pumpAndSettle();

  await _scrollDown(tester, 600);
  expect(find.text('رقم التليفون مسجّل بحساب تاني.'), findsOneWidget);
  expect(find.text('تم تأكيد حجزك!'), findsNothing);
});

testWidgets('البحث برقم المرجع يجلب حجزاً حقيقياً من BFF', (tester) async {
  final client = MockClient((request) async {
    expect(request.url.path, '/api/mobile/bookings/QW-TEST1234-AB12');
    return http.Response(
      jsonEncode(bookingBody()),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final repository = BookingRepository(client: ApiClient(httpClient: client));

  await tester.pumpWidget(MaterialApp(
    home: BookingsScreen(
      initialReference: 'QW-TEST1234-AB12',
      repository: repository,
    ),
    routes: {
      '/success': (context) => BookingSuccessScreen(
            booking: ModalRoute.of(context)!.settings.arguments as MobileBooking,
          ),
    },
  ));
  await tester.pumpAndSettle();

  expect(find.text('QW-TEST1234-AB12'), findsWidgets);
  expect(find.text('دار المدينة بإطلالة على النيل'), findsWidgets);
});
}
