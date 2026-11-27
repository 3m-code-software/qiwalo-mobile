import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qiwalo_app/api/api_client.dart';
import 'package:qiwalo_app/api/auth_repository.dart';
import 'package:qiwalo_app/api/role_repository.dart';

http.Response _json(Map<String, dynamic> body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  test('دخول المالك يرسل البريد والباسورد للـ BFF ويحتفظ بالتوكن', () async {
    late http.Request httpRequest;
    final client = MockClient((request) async {
      httpRequest = request;
      return _json({
        'ok': true,
        'token': 'test-jwt',
        'expiresIn': 604800,
        'user': {
          'email': 'owner@qiwalo.test',
          'name': 'مالك الاختبار',
          'role': 'OWNER',
        },
      });
    });

    final auth = AuthRepository(
      client: ApiClient(httpClient: client),
      useMock: false,
    );
    final session = await auth.signIn(
      email: 'owner@qiwalo.test',
      password: 'Qiwalo123',
    );

    expect(session.token, 'test-jwt');
    expect(session.user.name, 'مالك الاختبار');
    expect(session.user.role, 'OWNER');
    expect(httpRequest.url.path, '/api/mobile/auth/login');
    expect(jsonDecode(httpRequest.body)['password'], 'Qiwalo123');
    expect(await auth.savedToken, 'test-jwt');
  });

  test('بيانات المالك تُقرأ من BFF بالتوكن مع أسماء عربية', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      switch (request.url.path) {
        case '/api/mobile/owner/summary':
          return _json({
            'ok': true,
            'user': {'email': 'owner@qiwalo.test', 'name': 'مالك الاختبار', 'role': 'OWNER'},
            'summary': {
              'properties': 2,
              'published': 1,
              'draft': 1,
              'bookings': 1,
              'activeBookings': 1,
              'newRequests': 0,
              'rating': 4.8,
              'reviews': 3,
            },
          });
        case '/api/mobile/owner/properties':
          return _json({
            'ok': true,
            'properties': [
              {
                'id': 'p1',
                'name': 'دار المدينة',
                'cityAr': 'الأقصر',
                'statusAr': 'منشور',
                'basePrice': 1450,
              },
            ],
          });
        default:
          return _json({
            'ok': true,
            'bookings': [
              {
                'reference': 'QW-TEST-1',
                'propertyName': 'دار المدينة',
                'guestName': 'ضيف الاختبار',
                'checkIn': '2026-11-28',
                'checkOut': '2026-12-01',
                'total': 5439,
                'status': 'CONFIRMED',
              },
            ],
          });
      }
    });

    final snapshot = await RoleRepository(
      client: ApiClient(httpClient: client),
      useMock: false,
    ).load(role: 'OWNER', token: 'test-jwt');

    expect(requests.length, 3);
    expect(
      requests.every((request) => request.headers['authorization'] == 'Bearer test-jwt'),
      isTrue,
    );
    expect(snapshot.userName, 'مالك الاختبار');
    expect(snapshot.ownerSummary!.published, 1);
    expect(snapshot.ownerProperties.first.price, '١٬٤٥٠ ج.م');
    expect(snapshot.ownerBookings.first.guestName, 'ضيف الاختبار');
    expect(snapshot.ownerBookings.first.dates, '٢٨/١١/٢٠٢٦ ← ٠١/١٢/٢٠٢٦');
  });

  test('رحلات السائق مشتقة من حجوزات BFF بتفاصيل النقل', () async {
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/api/mobile/driver/summary':
          return _json({
            'ok': true,
            'user': {'email': 'driver@qiwalo.test', 'name': 'سائق الاختبار', 'role': 'DRIVER'},
            'summary': {
              'vehicles': 1,
              'available': 1,
              'trips': 1,
              'todayTrips': 1,
              'upcomingTrips': 1,
              'subscriptionAr': 'نشط',
              'verified': true,
            },
          });
        case '/api/mobile/driver/profile':
          return _json({
            'ok': true,
            'profile': {
              'name': 'سائق الاختبار',
              'phone': '01066094050',
              'cityAr': 'الأقصر',
              'subscriptionAr': 'نشط',
              'verificationStatus': 'APPROVED',
              'note': '',
            },
          });
        case '/api/mobile/driver/vehicles':
          return _json({
            'ok': true,
            'vehicles': [
              {
                'id': 'v1',
                'name': 'سيارة الاختبار',
                'cityAr': 'الأقصر',
                'plateNumber': 'LXR-1234',
                'model': 'تويوتا كامري',
                'capacity': 6,
                'pricePerTrip': 650,
                'routeFrom': 'الأقصر',
                'routeTo': 'وادي الملوك',
                'statusAr': 'منشور',
                'isPaused': false,
                'blockedDates': [],
              },
            ],
          });
        default:
          return _json({
            'ok': true,
            'trips': [
              {
                'id': 'b4',
                'reference': 'QW-SEED-4',
                'from': 'مطار الأقصر',
                'to': 'وادي الملوك',
                'date': '2026-11-28',
                'durationHours': 3,
                'guests': 2,
                'total': 650,
              },
            ],
          });
      }
    });

    final snapshot = await RoleRepository(
      client: ApiClient(httpClient: client),
      useMock: false,
    ).load(role: 'DRIVER', token: 'test-jwt');

    expect(snapshot.driverSummary!.todayTrips, 1);
    expect(snapshot.vehicles.first.plateNumber, 'LXR-1234');
    expect(snapshot.trips.length, 1);
    expect(snapshot.trips.first.id, 'QW-SEED-4');
    expect(snapshot.trips.first.fare, '٦٥٠ ج.م');
    expect(snapshot.trips.first.time, '٢٨/١١/٢٠٢٦');
    expect(snapshot.trips.first.passengers, '٢ راكب');
  });
}
