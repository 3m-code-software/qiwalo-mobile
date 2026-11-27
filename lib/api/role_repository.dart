import '../format.dart';
import '../owner_driver_data.dart' as preview;
import 'api_client.dart';

class MobileOwnerSummary {
  const MobileOwnerSummary({
    required this.properties,
    required this.published,
    required this.draft,
    required this.bookings,
    required this.activeBookings,
    required this.newRequests,
    required this.rating,
    required this.reviews,
  });

  final int properties;
  final int published;
  final int draft;
  final int bookings;
  final int activeBookings;
  final int newRequests;
  final double rating;
  final int reviews;

  factory MobileOwnerSummary.fromJson(Map<String, dynamic> json) => MobileOwnerSummary(
        properties: _int(json['properties']),
        published: _int(json['published']),
        draft: _int(json['draft']),
        bookings: _int(json['bookings']),
        activeBookings: _int(json['activeBookings']),
        newRequests: _int(json['newRequests']),
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviews: _int(json['reviews']),
      );
}

class MobileOwnerProperty {
  const MobileOwnerProperty({
    required this.id,
    required this.name,
    required this.cityAr,
    required this.statusAr,
    required this.price,
  });

  final String id;
  final String name;
  final String cityAr;
  final String statusAr;
  final String price;

  factory MobileOwnerProperty.fromJson(Map<String, dynamic> json) => MobileOwnerProperty(
        id: _text(json['id']),
        name: _text(json['name'], fallback: 'وحدة قيوالو'),
        cityAr: _text(json['cityAr']),
        statusAr: _text(json['statusAr']),
        price: json['basePrice'] == null
            ? _text(json['price'], fallback: '—')
            : money(json['basePrice']),
      );
}

class MobileOwnerBooking {
  const MobileOwnerBooking({
    required this.reference,
    required this.propertyName,
    required this.guestName,
    required this.dates,
    required this.total,
    required this.status,
  });

  final String reference;
  final String propertyName;
  final String guestName;
  final String dates;
  final String total;
  final String status;

  factory MobileOwnerBooking.fromJson(Map<String, dynamic> json) => MobileOwnerBooking(
        reference: _text(json['reference']),
        propertyName: _text(json['propertyName'], fallback: 'وحدة قيوالو'),
        guestName: _text(json['guestName'], fallback: 'ضيف قيوالو'),
        dates: '${dateAr(_text(json['checkIn']))} ← ${dateAr(_text(json['checkOut']))}',
        total: money(json['total'] ?? 0),
        status: _text(json['status']),
      );

  static MobileOwnerBooking fromPreview(preview.OwnerBookingRow row) => MobileOwnerBooking(
        reference: row.reference,
        propertyName: row.stay,
        guestName: row.guest,
        dates: row.dates,
        total: row.total,
        status: row.status == 'مؤكد' ? 'CONFIRMED' : 'PENDING',
      );
}

class MobileDriverSummary {
  const MobileDriverSummary({
    required this.vehicles,
    required this.available,
    required this.trips,
    required this.todayTrips,
    required this.upcomingTrips,
    required this.subscriptionAr,
    required this.verified,
  });

  final int vehicles;
  final int available;
  final int trips;
  final int todayTrips;
  final int upcomingTrips;
  final String subscriptionAr;
  final bool verified;

  factory MobileDriverSummary.fromJson(Map<String, dynamic> json) => MobileDriverSummary(
        vehicles: _int(json['vehicles']),
        available: _int(json['available']),
        trips: _int(json['trips']),
        todayTrips: _int(json['todayTrips']),
        upcomingTrips: _int(json['upcomingTrips']),
        subscriptionAr: _text(json['subscriptionAr']),
        verified: json['verified'] == true,
      );
}

class MobileDriverProfile {
  const MobileDriverProfile({
    required this.name,
    required this.phone,
    required this.cityAr,
    required this.subscriptionAr,
    required this.verificationStatus,
    required this.note,
  });

  final String name;
  final String phone;
  final String cityAr;
  final String subscriptionAr;
  final String verificationStatus;
  final String note;

  factory MobileDriverProfile.fromJson(Map<String, dynamic> json) => MobileDriverProfile(
        name: _text(json['name'], fallback: 'سائق قيوالو'),
        phone: _text(json['phone']),
        cityAr: _text(json['cityAr']),
        subscriptionAr: _text(json['subscriptionAr']),
        verificationStatus: _text(json['verificationStatus']),
        note: _text(json['note']),
      );
}

class MobileVehicle {
  const MobileVehicle({
    required this.id,
    required this.name,
    required this.cityAr,
    required this.plateNumber,
    required this.model,
    required this.capacity,
    required this.pricePerTrip,
    required this.routeFrom,
    required this.routeTo,
    required this.statusAr,
    required this.isPaused,
    required this.blockedDates,
  });

  final String id;
  final String name;
  final String cityAr;
  final String plateNumber;
  final String model;
  final int capacity;
  final num pricePerTrip;
  final String routeFrom;
  final String routeTo;
  final String statusAr;
  final bool isPaused;
  final List<String> blockedDates;

  factory MobileVehicle.fromJson(Map<String, dynamic> json) => MobileVehicle(
        id: _text(json['id']),
        name: _text(json['name'], fallback: 'مركبة قيوالو'),
        cityAr: _text(json['cityAr']),
        plateNumber: _text(json['plateNumber']),
        model: _text(json['model']),
        capacity: _int(json['capacity']),
        pricePerTrip: json['pricePerTrip'] is num ? json['pricePerTrip'] as num : 0,
        routeFrom: _text(json['routeFrom']),
        routeTo: _text(json['routeTo']),
        statusAr: _text(json['statusAr']),
        isPaused: json['isPaused'] == true,
        blockedDates: (json['blockedDates'] as List? ?? const [])
            .map((item) => item.toString())
            .toList(),
      );
}

/// كل بيانات الأدوار اللي بتحتاجها الشاشات الثماني في كائن واحد.
class RoleSnapshot {
  const RoleSnapshot({
    required this.ownerSummary,
    required this.ownerProperties,
    required this.ownerBookings,
    required this.driverSummary,
    required this.driverProfile,
    required this.vehicles,
    required this.trips,
    required this.userName,
    this.fromMock = false,
  });

  final MobileOwnerSummary? ownerSummary;
  final List<MobileOwnerProperty> ownerProperties;
  final List<MobileOwnerBooking> ownerBookings;
  final MobileDriverSummary? driverSummary;
  final MobileDriverProfile? driverProfile;
  final List<MobileVehicle> vehicles;
  final List<preview.DriverTrip> trips;
  final String userName;
  final bool fromMock;

  factory RoleSnapshot.mock() => RoleSnapshot(
        ownerSummary: const MobileOwnerSummary(
          properties: 3,
          published: 2,
          draft: 1,
          bookings: 2,
          activeBookings: 2,
          newRequests: 1,
          rating: 4.8,
          reviews: 3,
        ),
        ownerProperties: const [
          MobileOwnerProperty(id: 'p1', name: 'دار المدينة بإطلالة على النيل', cityAr: 'الأقصر', statusAr: 'منشورة', price: '١٬٤٥٠ ج.م'),
          MobileOwnerProperty(id: 'p2', name: 'نزل النخيل', cityAr: 'أسوان', statusAr: 'منشورة', price: '١٬١٠٠ ج.م'),
          MobileOwnerProperty(id: 'p3', name: 'فيلا الوادي', cityAr: 'الأقصر', statusAr: 'مسودة', price: '٢٬٣٠٠ ج.م'),
        ],
        ownerBookings: preview.ownerBookings.map(MobileOwnerBooking.fromPreview).toList(),
        driverSummary: const MobileDriverSummary(
          vehicles: 1,
          available: 1,
          trips: 3,
          todayTrips: 2,
          upcomingTrips: 3,
          subscriptionAr: 'نشط',
          verified: true,
        ),
        driverProfile: const MobileDriverProfile(
          name: 'سائق قيوالو',
          phone: '01066094050',
          cityAr: 'الأقصر',
          subscriptionAr: 'نشط',
          verificationStatus: 'APPROVED',
          note: '',
        ),
        vehicles: const [
          MobileVehicle(
            id: 'v1',
            name: 'سيارة السائق — جولات الأقصر',
            cityAr: 'الأقصر',
            plateNumber: 'LXR-1234',
            model: 'تويوتا كامري ٢٠٢٢',
            capacity: 6,
            pricePerTrip: 650,
            routeFrom: 'الأقصر الشرقية',
            routeTo: 'وادي الملوك',
            statusAr: 'منشورة',
            isPaused: false,
            blockedDates: [],
          ),
        ],
        trips: preview.driverTrips,
        userName: 'محمد مالك',
        fromMock: true,
      );
}

/// كل القراءة والكتابة تمر على BFF؛ مفيش Supabase أو أسعار جوه Dart.
class RoleRepository {
  const RoleRepository({ApiClient? client, bool? useMock})
      : _client = client,
        useMock = useMock ?? defaultUseMock;

  final ApiClient? _client;
  final bool useMock;

  static const bool defaultUseMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  ApiClient get effectiveClient => _client ?? ApiClient();

  Future<RoleSnapshot> load({
    required String role,
    required String token,
  }) async {
    if (useMock) return RoleSnapshot.mock();

    final client = effectiveClient;
    if (role == 'OWNER') {
      final results = await Future.wait([
        client.getMap('/api/mobile/owner/summary', token: token),
        client.getMap('/api/mobile/owner/properties', token: token),
        client.getMap('/api/mobile/owner/bookings', token: token),
      ]);
      for (final body in results) {
        if (body['ok'] != true) {
          throw ApiException(_note(body, fallback: 'تعذّر تحميل بيانات المالك'));
        }
      }
      return RoleSnapshot(
        ownerSummary: MobileOwnerSummary.fromJson(_map(results[0]['summary'])),
        ownerProperties: (_rows(results[1]['properties']))
            .map((row) => MobileOwnerProperty.fromJson(row))
            .toList(),
        ownerBookings: (_rows(results[2]['bookings']))
            .map((row) => MobileOwnerBooking.fromJson(row))
            .toList(),
        // الأدوار منفصلة؛ ما نطلبش بيانات السائق لما المستخدم مالك.
        driverSummary: null,
        driverProfile: null,
        vehicles: const [],
        trips: const [],
        userName: _text(_map(results[0]['user'])['name'], fallback: 'مالك قيوالو'),
      );
    }

    final results = await Future.wait([
      client.getMap('/api/mobile/driver/summary', token: token),
      client.getMap('/api/mobile/driver/profile', token: token),
      client.getMap('/api/mobile/driver/vehicles', token: token),
      client.getMap('/api/mobile/driver/trips', token: token),
    ]);
    for (final body in results) {
      if (body['ok'] != true) {
        throw ApiException(_note(body, fallback: 'تعذّر تحميل بيانات السائق'));
      }
    }
    return RoleSnapshot(
      ownerSummary: null,
      ownerProperties: const [],
      ownerBookings: const [],
      driverSummary: MobileDriverSummary.fromJson(_map(results[0]['summary'])),
      driverProfile: MobileDriverProfile.fromJson(_map(results[1]['profile'])),
      vehicles: (_rows(results[2]['vehicles']))
          .map((row) => MobileVehicle.fromJson(row))
          .toList(),
      trips: (_rows(results[3]['trips']))
          .map((row) => preview.DriverTrip.fromRoleJson(row))
          .toList(),
      userName: _text(_map(results[0]['user'])['name'], fallback: 'سائق قيوالو'),
    );
  }

  Future<MobileOwnerProperty?> saveOwnerProperty({
    required String token,
    String? id,
    required String name,
    required String cityAr,
    required int price,
  }) async {
    if (useMock) return null;
    final city = cityAr.contains('أسوان') ? 'ASWAN' : 'LUXOR';
    final body = <String, dynamic>{
      'name': name,
      'type': 'APARTMENT',
      'city': city,
      'address': 'عنوان الوحدة',
      'description': '',
      'lat': city == 'LUXOR' ? 25.6872 : 24.0889,
      'lng': city == 'LUXOR' ? 32.6396 : 32.8998,
      'images': const [],
      'amenities': const [],
      'maxGuests': 4,
      'bedrooms': 2,
      'bathrooms': 1,
      'basePrice': price,
      'cancelPolicy': 'FREE_48H',
    };
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    final response = id == null
        ? await effectiveClient.postMap(
            '/api/mobile/owner/properties',
            headers: headers,
            body: body,
          )
        : await effectiveClient.patchMap(
            '/api/mobile/owner/properties/${Uri.encodeComponent(id)}',
            headers: headers,
            body: body,
          );
    if (response['ok'] != true) {
      throw ApiException(_note(response, fallback: 'تعذّر حفظ الوحدة'));
    }
    return MobileOwnerProperty.fromJson(_map(response['property']));
  }

  Future<void> setVehiclePaused({
    required String token,
    required String id,
    required bool paused,
  }) async {
    if (useMock) return;
    final response = await effectiveClient.patchMap(
      '/api/mobile/driver/vehicles/${Uri.encodeComponent(id)}/pause',
      headers: {'Authorization': 'Bearer $token'},
      body: {'paused': paused},
    );
    if (response['ok'] != true) {
      throw ApiException(_note(response, fallback: 'تعذّر تحديث حالة المركبة'));
    }
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? value.cast<String, dynamic>() : <String, dynamic>{};

List<Map<String, dynamic>> _rows(Object? value) => value is List
    ? value.whereType<Map>().map((row) => row.cast<String, dynamic>()).toList()
    : <Map<String, dynamic>>[];

String _note(Map<String, dynamic> body, {required String fallback}) {
  final note = body['note'];
  return note is String && note.isNotEmpty ? note : fallback;
}

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

int _int(Object? value) => value is num ? value.toInt() : 0;
