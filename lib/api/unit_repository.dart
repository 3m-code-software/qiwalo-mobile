import 'api_client.dart';
import 'mock_data.dart';

/// كل البيانات القادمة من `/api/mobile/units/[slug]`، بنفس أسماء الحقول.
class UnitReview {
  const UnitReview({
    required this.rating,
    required this.comment,
    required this.guestName,
    required this.createdAt,
    this.ownerReply,
  });

  final num rating;
  final String comment;
  final String guestName;
  final String createdAt;
  final String? ownerReply;

  factory UnitReview.fromJson(Map<String, dynamic> json) => UnitReview(
        rating: (json['rating'] as num?) ?? 0,
        comment: _text(json['comment']),
        guestName: _text(json['guestName']),
        createdAt: _text(json['createdAt']),
        ownerReply: json['ownerReply'] == null ? null : _text(json['ownerReply']),
      );
}

class AvailabilityDay {
  const AvailabilityDay({
    required this.date,
    required this.isBlocked,
    this.priceOverride,
  });

  final String date;
  final bool isBlocked;
  final num? priceOverride;

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) => AvailabilityDay(
        date: _text(json['date']),
        isBlocked: json['isBlocked'] == true,
        priceOverride: json['priceOverride'] as num?,
      );
}

class PriceRuleInfo {
  const PriceRuleInfo({
    required this.name,
    required this.price,
    required this.minNights,
  });

  final String name;
  final num price;
  final int minNights;

  factory PriceRuleInfo.fromJson(Map<String, dynamic> json) => PriceRuleInfo(
        name: _text(json['name']),
        price: (json['price'] as num?) ?? 0,
        minNights: (json['minNights'] as num?)?.toInt() ?? 1,
      );
}

class UnitDetail {
  const UnitDetail({
    required this.slug,
    required this.name,
    required this.host,
    required this.typeAr,
    required this.cityAr,
    required this.address,
    required this.description,
    required this.images,
    required this.amenities,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqm,
    required this.basePrice,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.cancellation,
    required this.houseRules,
    required this.lat,
    required this.lng,
    required this.reviews,
    required this.availability,
    required this.priceRules,
    required this.pagePath,
    required this.supportPhone,
    required this.whatsapp,
    required this.telegram,
    required this.paymentCopy,
    this.fromMock = false,
  });

  final String slug;
  final String name;
  final String host;
  final String typeAr;
  final String cityAr;
  final String address;
  final String description;
  final List<String> images;
  final List<String> amenities;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final int? areaSqm;
  final num basePrice;
  final String currency;
  final num rating;
  final int reviewCount;
  final String cancellation;
  final String houseRules;
  final num lat;
  final num lng;
  final List<UnitReview> reviews;
  final List<AvailabilityDay> availability;
  final List<PriceRuleInfo> priceRules;
  final String pagePath;
  final String supportPhone;
  final String whatsapp;
  final String telegram;
  final String paymentCopy;
  final bool fromMock;

  factory UnitDetail.fromJson(Map<String, dynamic> json) {
    final unit = (json['unit'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final support = (json['support'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return UnitDetail(
      slug: _text(unit['slug']),
      name: _text(unit['name']),
      host: _text(unit['host']),
      typeAr: _text(unit['typeAr']),
      cityAr: _text(unit['cityAr']),
      address: _text(unit['address']),
      description: _text(unit['description']),
      images: _stringList(unit['images']),
      amenities: _stringList(unit['amenities']),
      maxGuests: _int(unit['maxGuests']),
      bedrooms: _int(unit['bedrooms']),
      bathrooms: _int(unit['bathrooms']),
      areaSqm: unit['areaSqm'] == null ? null : _int(unit['areaSqm']),
      basePrice: (unit['basePrice'] as num?) ?? 0,
      currency: _text(unit['currency'], fallback: 'EGP'),
      rating: (unit['rating'] as num?) ?? 0,
      reviewCount: _int(unit['reviewCount']),
      cancellation: _text(unit['cancellation']),
      houseRules: _text(unit['houseRules']),
      lat: (unit['lat'] as num?) ?? 0,
      lng: (unit['lng'] as num?) ?? 0,
      reviews: (json['reviews'] as List? ?? const [])
          .whereType<Map>()
          .map((r) => UnitReview.fromJson(r.cast<String, dynamic>()))
          .toList(),
      availability: (json['availability'] as List? ?? const [])
          .whereType<Map>()
          .map((a) => AvailabilityDay.fromJson(a.cast<String, dynamic>()))
          .toList(),
      priceRules: (json['priceRules'] as List? ?? const [])
          .whereType<Map>()
          .map((p) => PriceRuleInfo.fromJson(p.cast<String, dynamic>()))
          .toList(),
      pagePath: _text(json['pagePath']),
      supportPhone: _text(support['phone']),
      whatsapp: _text(support['whatsapp']),
      telegram: _text(support['telegram']),
      paymentCopy: _text(json['paymentCopy']),
    );
  }

  UnitDetail copyWithMockFlag() => UnitDetail(
        slug: slug,
        name: name,
        host: host,
        typeAr: typeAr,
        cityAr: cityAr,
        address: address,
        description: description,
        images: images,
        amenities: amenities,
        maxGuests: maxGuests,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        areaSqm: areaSqm,
        basePrice: basePrice,
        currency: currency,
        rating: rating,
        reviewCount: reviewCount,
        cancellation: cancellation,
        houseRules: houseRules,
        lat: lat,
        lng: lng,
        reviews: reviews,
        availability: availability,
        priceRules: priceRules,
        pagePath: pagePath,
        supportPhone: supportPhone,
        whatsapp: whatsapp,
        telegram: telegram,
        paymentCopy: paymentCopy,
        fromMock: true,
      );
}

/// يقرأ تفاصيل وحدة من BFF. لو الخادم مش متاح (أو تم بناء APK بـ USE_MOCK=true)
/// يرجّع نسخة معاينة محلية مع علامة واضحة في الواجهة.
class UnitRepository {
  const UnitRepository({ApiClient? client, bool? useMock})
      : _client = client,
        useMock = useMock ?? defaultUseMock;

  final ApiClient? _client;
  final bool useMock;

  ApiClient get effectiveClient => _client ?? ApiClient();

  static const bool defaultUseMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  Future<UnitDetail> fetchUnit(String slug) async {
    if (useMock) return mockUnitDetail;

    try {
      final body = await effectiveClient.getMap(
        '/api/mobile/units/${Uri.encodeComponent(slug)}',
      );
      if (body['ok'] != true) {
        throw ApiException(_text(body['note'], fallback: 'الوحدة غير متاحة'));
      }
      return UnitDetail.fromJson(body);
    } catch (_) {
      // أي فشل في الشبكة أو في تحليل الاستجابة لا يجب أن يفرغ شاشة الوحدة.
      return mockUnitDetail.copyWithMockFlag();
    }
  }
}

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

int _int(Object? value) => (value is num ? value.toInt() : 0);

List<String> _stringList(Object? value) {
  final list = value is List ? value : const <dynamic>[];
  return list
      .whereType<String>()
      .where((item) => item.isNotEmpty)
      .toList();
}
