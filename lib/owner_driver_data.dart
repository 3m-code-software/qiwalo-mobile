import 'package:flutter/material.dart';

import 'format.dart';

/// بيانات محلية لمعاينة شاشات المالك والسائق.
/// لسه مفيش BFF لهذه الأدوار؛ كل الأزرار هنا معاينة واجهة فقط.
class OwnerUnitRow {
  final String name;
  final String city;
  final String status;
  final String price;
  final String occupancy;

  const OwnerUnitRow({
    required this.name,
    required this.city,
    required this.status,
    required this.price,
    required this.occupancy,
  });
}

const List<OwnerUnitRow> ownerUnits = [
  OwnerUnitRow(
    name: 'دار المدينة بإطلالة على النيل',
    city: 'الأقصر',
    status: 'منشورة',
    price: '١٬٤٥٠ ج.م / ليلة',
    occupancy: '٧٢٪',
  ),
  OwnerUnitRow(
    name: 'نزل النخيل',
    city: 'أسوان',
    status: 'منشورة',
    price: '١٬١٠٠ ج.م / ليلة',
    occupancy: '٥٤٪',
  ),
  OwnerUnitRow(
    name: 'فيلا الوادي',
    city: 'الأقصر',
    status: 'مسودة',
    price: '٢٬٣٠٠ ج.م / ليلة',
    occupancy: '—',
  ),
];

class OwnerBookingRow {
  final String reference;
  final String stay;
  final String guest;
  final String dates;
  final String total;
  final String status;

  const OwnerBookingRow({
    required this.reference,
    required this.stay,
    required this.guest,
    required this.dates,
    required this.total,
    required this.status,
  });
}

const List<OwnerBookingRow> ownerBookings = [
  OwnerBookingRow(
    reference: 'QW-MWXP480N-419L',
    stay: 'دار المدينة بإطلالة على النيل',
    guest: 'ضيف محجوز',
    dates: '٢٨ ← ٣١ مارس ٢٠٢٧',
    total: '٤٬٥٦٩ ج.م',
    status: 'قيد الانتظار',
  ),
  OwnerBookingRow(
    reference: 'QW-MWUNMFL2-Q364',
    stay: 'نزل النخيل',
    guest: 'ضيف مؤكد',
    dates: '١٢ ← ١٤ يونيو ٢٠٢٧',
    total: '٢٬٣٨٠ ج.م',
    status: 'مؤكد',
  ),
];

class DriverTrip {
  final String id;
  final String from;
  final String to;
  final String time;
  final String fare;
  final String distance;
  final String passengers;
  final IconData icon;

  const DriverTrip({
    required this.id,
    required this.from,
    required this.to,
    required this.time,
    required this.fare,
    required this.distance,
    required this.passengers,
    required this.icon,
  });

  /// رحلة BFF مشتقّة من حجز؛ الأرقام والتواريخ تُنسّق عربياً هنا لا في الخادم.
  factory DriverTrip.fromRoleJson(Map<String, dynamic> json) => DriverTrip(
        id: _string(json['reference'], fallback: _string(json['id'], fallback: '—')),
        from: _string(json['from']),
        to: _string(json['to']),
        time: dateAr(_string(json['date'], fallback: '1970-01-01')),
        fare: money(json['total'] ?? json['pricePerTrip'] ?? 0),
        distance: '${arabicDigits(json['durationHours'] ?? 0)} ساعة',
        passengers: '${arabicDigits(json['guests'] ?? 0)} راكب',
        icon: Icons.route_rounded,
      );
}

String _string(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

const List<DriverTrip> driverTrips = [
  DriverTrip(
    id: 'TR-١٠٢',
    from: 'مطار الأقصر',
    to: 'دار المدينة بإطلالة على النيل',
    time: 'اليوم · ٦:٣٠ م',
    fare: '٣٢٠ ج.م',
    distance: '١٨ كم',
    passengers: '٢ راكب',
    icon: Icons.flight_takeoff_rounded,
  ),
  DriverTrip(
    id: 'TR-١٠٣',
    from: 'الكارنك',
    to: 'فندق النيل',
    time: 'اليوم · ٨:١٥ م',
    fare: '١٨٠ ج.م',
    distance: '٩ كم',
    passengers: '١ راكب',
    icon: Icons.tour_rounded,
  ),
  DriverTrip(
    id: 'TR-١٠٤',
    from: 'وادي الملوك',
    to: 'محطة القطار',
    time: 'غداً · ٩:٠٠ ص',
    fare: '٢٤٠ ج.م',
    distance: '١٤ كم',
    passengers: '٣ ركاب',
    icon: Icons.account_balance_rounded,
  ),
];
