import 'dart:math';

import '../format.dart';
import 'api_client.dart';

/// البيانات اللي بتتنقل من شاشة الوحدة لشاشة الحجز — assessment من الخادم، مش أسعار.
class BookingDraft {
  const BookingDraft({
    required this.slug,
    required this.unitName,
    required this.cityAr,
    required this.checkIn,
    required this.checkOut,
    this.guests = 2,
    this.maxGuests = 5,
  });

  final String slug;
  final String unitName;
  final String cityAr;
  final String checkIn;
  final String checkOut;
  final int guests;
  final int maxGuests;

  BookingDraft copyWith({
    String? checkIn,
    String? checkOut,
    int? guests,
  }) =>
      BookingDraft(
        slug: slug,
        unitName: unitName,
        cityAr: cityAr,
        checkIn: checkIn ?? this.checkIn,
        checkOut: checkOut ?? this.checkOut,
        guests: guests ?? this.guests,
        maxGuests: maxGuests,
      );
}

class QuoteNight {
  const QuoteNight({required this.date, required this.price, this.ruleName});

  final String date;
  final num price;
  final String? ruleName;

  factory QuoteNight.fromJson(Map<String, dynamic> json) => QuoteNight(
        date: _text(json['date']),
        price: (json['price'] as num?) ?? 0,
        ruleName: json['ruleName'] == null ? null : _text(json['ruleName']),
      );
}

class QuoteAddOn {
  const QuoteAddOn({required this.id, required this.label, required this.amount});

  final String id;
  final String label;
  final num amount;

  factory QuoteAddOn.fromJson(Map<String, dynamic> json) => QuoteAddOn(
        id: _text(json['id']),
        label: _text(json['label']),
        amount: (json['amount'] as num?) ?? 0,
      );
}

/// التسعير القادم من BFF. أي تعديل في قواعد الأسعار في الويب ينعكس هنا فوراً.
class BookingQuote {
  const BookingQuote({
    required this.nights,
    required this.nightly,
    required this.subtotal,
    required this.serviceFee,
    required this.commission,
    required this.total,
    required this.addOns,
    required this.grandTotal,
    required this.paymentCopy,
    this.fromMock = false,
  });

  final int nights;
  final List<QuoteNight> nightly;
  final num subtotal;
  final num serviceFee;
  final num commission;
  final num total;
  final List<QuoteAddOn> addOns;
  final num grandTotal;
  final String paymentCopy;
  final bool fromMock;

  factory BookingQuote.fromJson(Map<String, dynamic> json, {bool fromMock = false}) =>
      BookingQuote(
        nights: _int(json['nights']),
        nightly: (json['nightly'] as List? ?? const [])
            .whereType<Map>()
            .map((row) => QuoteNight.fromJson(row.cast<String, dynamic>()))
            .toList(),
        subtotal: (json['subtotal'] as num?) ?? 0,
        serviceFee: (json['serviceFee'] as num?) ?? 0,
        commission: (json['commission'] as num?) ?? 0,
        total: (json['total'] as num?) ?? 0,
        addOns: (json['addOns'] as List? ?? const [])
            .whereType<Map>()
            .map((row) => QuoteAddOn.fromJson(row.cast<String, dynamic>()))
            .toList(),
        grandTotal: (json['grandTotal'] as num?) ?? 0,
        paymentCopy: _text(json['paymentCopy']),
        fromMock: fromMock,
      );

  static const BookingQuote preview = BookingQuote(
    nights: 3,
    nightly: [
      QuoteNight(date: '2026-11-30', price: 1523),
      QuoteNight(date: '2026-12-01', price: 1523),
      QuoteNight(date: '2026-12-02', price: 1523),
    ],
    subtotal: 4569,
    serviceFee: 0,
    commission: 548,
    total: 4569,
    addOns: [],
    grandTotal: 4569,
    paymentCopy: 'تحويل بنكي أو كاش عند الوصول',
    fromMock: true,
  );
}

class BookingSupport {
  const BookingSupport({
    required this.phone,
    required this.whatsapp,
    required this.telegram,
  });

  final String phone;
  final String whatsapp;
  final String telegram;

  factory BookingSupport.fromJson(Map<String, dynamic> json) => BookingSupport(
        phone: _text(json['phone']),
        whatsapp: _text(json['whatsapp']),
        telegram: _text(json['telegram']),
      );
}

/// الحجز المؤكد كما يرجعه BFF — بدون أي بيانات شخصية للضيف.
class MobileBooking {
  const MobileBooking({
    required this.reference,
    required this.propertyName,
    required this.cityAr,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guests,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
    required this.paymentCopy,
    required this.support,
    required this.pagePath,
    this.fromMock = false,
  });

  final String reference;
  final String propertyName;
  final String cityAr;
  final String checkIn;
  final String checkOut;
  final int nights;
  final int guests;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final num total;
  final String createdAt;
  final String paymentCopy;
  final BookingSupport support;
  final String pagePath;
  final bool fromMock;

  factory MobileBooking.fromJson(Map<String, dynamic> json, {bool fromMock = false}) {
    final support = (json['support'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return MobileBooking(
      reference: _text(json['reference']),
      propertyName: _text(json['propertyName']),
      cityAr: _text(json['cityAr']),
      checkIn: _text(json['checkIn']),
      checkOut: _text(json['checkOut']),
      nights: _int(json['nights']),
      guests: _int(json['guests']),
      status: _text(json['status']),
      paymentStatus: _text(json['paymentStatus']),
      paymentMethod: _text(json['paymentMethod'], fallback: 'CASH'),
      total: (json['total'] as num?) ?? 0,
      createdAt: _text(json['createdAt']),
      paymentCopy: _text(json['paymentCopy']),
      support: BookingSupport.fromJson(support),
      pagePath: _text(json['pagePath']),
      fromMock: fromMock,
    );
  }

  static MobileBooking preview(String paymentMethod, num total) => MobileBooking(
        reference: 'PREVIEW-${arabicDigits(DateTime.now().millisecondsSinceEpoch)}',
        propertyName: 'دار المدينة بإطلالة على النيل',
        cityAr: 'الأقصر',
        checkIn: '2026-11-30',
        checkOut: '2026-12-03',
        nights: 3,
        guests: 2,
        status: 'CONFIRMED',
        paymentStatus: 'PENDING',
        paymentMethod: paymentMethod,
        total: total,
        createdAt: DateTime.now().toIso8601String(),
        paymentCopy: 'تحويل بنكي أو كاش عند الوصول',
        support: const BookingSupport(
          phone: '01066094050',
          whatsapp: 'https://wa.me/201066094050',
          telegram: 'https://t.me/+201066094050',
        ),
        pagePath: '/booking/PREVIEW',
        fromMock: true,
      );
}

/// كل طلبات الحجز تمر على الـ BFF. مفيش Supabase ولا منطق أسعار جوه التطبيق.
class BookingRepository {
  const BookingRepository({ApiClient? client, bool? useMock})
      : _client = client,
        useMock = useMock ?? defaultUseMock;

  final ApiClient? _client;
  final bool useMock;

  static const bool defaultUseMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  ApiClient get effectiveClient => _client ?? ApiClient();

  /// مفتاح ثابت لنفس محاولة الحجز، عشان إعادة الإرسال ما تعملش حجزين.
  static String newIdempotencyKey() {
    final random = Random();
    return 'qw-${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 30)}';
  }

  Future<BookingQuote> quote({
    required String slug,
    required String checkIn,
    required String checkOut,
    required int guests,
  }) async {
    if (useMock) return BookingQuote.preview;
    final body = await effectiveClient.postMap('/api/mobile/bookings/quote', body: {
      'slug': slug,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
    });
    if (body['ok'] != true) {
      throw ApiException(_note(body, fallback: 'تعذّر حساب السعر'));
    }
    return BookingQuote.fromJson(
      (body['quote'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }

  Future<MobileBooking> confirm({
    required BookingDraft draft,
    required String fullName,
    required String email,
    required String phone,
    required String nationality,
    required String paymentMethod,
    required String idempotencyKey,
  }) async {
    if (useMock) {
      return MobileBooking.preview(paymentMethod, BookingQuote.preview.grandTotal);
    }
    final body = await effectiveClient.postMap(
      '/api/mobile/bookings',
      headers: {'Idempotency-Key': idempotencyKey},
      body: {
        'slug': draft.slug,
        'checkIn': draft.checkIn,
        'checkOut': draft.checkOut,
        'guests': draft.guests,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'nationality': nationality,
        'paymentMethod': paymentMethod,
        'termsAccepted': true,
      },
    );
    if (body['ok'] != true) {
      throw ApiException(_note(body, fallback: 'تعذّر تأكيد الحجز'));
    }
    return MobileBooking.fromJson(
      (body['booking'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }

  Future<MobileBooking> lookup(String reference) async {
    if (useMock) return MobileBooking.preview('CASH', BookingQuote.preview.grandTotal);
    final safe = reference.trim().replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');
    if (safe.isEmpty) throw const ApiException('أدخل رقم حجز صحيح.');
    final body = await effectiveClient.getMap(
      '/api/mobile/bookings/${Uri.encodeComponent(safe)}',
    );
    if (body['ok'] != true) {
      throw ApiException(_note(body, fallback: 'الحجز غير موجود'));
    }
    return MobileBooking.fromJson(
      (body['booking'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }
}

String _note(Map<String, dynamic> body, {required String fallback}) {
  final note = body['note'];
  return note is String && note.isNotEmpty ? note : fallback;
}

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

int _int(Object? value) => value is num ? value.toInt() : 0;
