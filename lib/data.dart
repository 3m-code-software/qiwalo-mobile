import 'package:flutter/material.dart';

class Stay {
  final String slug;
  final String name;
  final String city;
  final String type;
  final String price;
  final String rating;
  final String description;
  final IconData icon;
  final Color color;

  const Stay({
    required this.slug,
    required this.name,
    required this.city,
    required this.type,
    required this.price,
    required this.rating,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<Stay> sampleStays = [
  Stay(
    slug: 'nile-view-dar-al-madina',
    name: 'دار المدينة بإطلالة على النيل',
    city: 'الأقصر',
    type: 'شقة · غرفتان',
    price: '١٬٤٥٠ ج.م / ليلة',
    rating: '٤٫٨',
    description: 'دقائق من الكرنك ووادي الملوك، مع تراس بإطلالة مباشرة على النيل.',
    icon: Icons.apartment_rounded,
    color: Color(0xFF1E5A74),
  ),
  Stay(
    slug: 'aswan-nubian-house',
    name: 'نزل النخيل',
    city: 'أسوان',
    type: 'نزل · ٣ غرف',
    price: '١٬١٠٠ ج.م / ليلة',
    rating: '٤٫٦',
    description: 'إطلالة هادية على النيل وقريب من جزيرة الفنتين.',
    icon: Icons.hotel_rounded,
    color: Color(0xFF8A5A2B),
  ),
  Stay(
    slug: 'luxor-west-bank-villa',
    name: 'فيلا الوادي',
    city: 'الأقصر',
    type: 'فيلا · ٤ غرف',
    price: '٢٬٣٠٠ ج.م / ليلة',
    rating: '٤٫٩',
    description: 'مساحة واسعة ومسبح خاص، مناسبة للعائلات والمجموعات.',
    icon: Icons.villa_rounded,
    color: Color(0xFF3E6B52),
  ),
];

class ServiceOption {
  final String title;
  final String subtitle;
  final String price;
  final IconData icon;

  const ServiceOption({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
  });
}

const List<ServiceOption> sampleServices = [
  ServiceOption(
    title: 'سفاري الجبال',
    subtitle: 'رحلة إرشادية لمدة نصف يوم',
    price: '+ ٦٥٠ ج.م',
    icon: Icons.terrain_rounded,
  ),
  ServiceOption(
    title: 'نقل من المطار',
    subtitle: 'سيارة خاصة · ٤ مقاعد',
    price: '+ ٣٢٠ ج.م',
    icon: Icons.directions_car_rounded,
  ),
  ServiceOption(
    title: 'باقة الإقامة',
    subtitle: 'إقامة + سفاري + نقل',
    price: '+ ٩٩٠ ج.م / ليلة',
    icon: Icons.all_inclusive_rounded,
  ),
];

class SampleBooking {
  final String reference;
  final String stay;
  final String dates;
  final String guests;
  final String total;
  final String status;

  const SampleBooking({
    required this.reference,
    required this.stay,
    required this.dates,
    required this.guests,
    required this.total,
    required this.status,
  });
}

const List<SampleBooking> sampleBookings = [
  SampleBooking(
    reference: 'QW-MWXP480N-419L',
    stay: 'دار المدينة بإطلالة على النيل',
    dates: '٢٥ ← ٢٨ مايو ٢٠٢٧',
    guests: '٢ ضيف',
    total: '٤٬٥٦٩ ج.م',
    status: 'قيد الانتظار',
  ),
  SampleBooking(
    reference: 'QW-MWUNMFL2-Q364',
    stay: 'نزل النخيل',
    dates: '١٢ ← ١٤ يونيو ٢٠٢٧',
    guests: '١ ضيف',
    total: '٢٬٣٨٠ ج.م',
    status: 'مؤكد',
  ),
];

class PriceLine {
  final String label;
  final String value;

  const PriceLine(this.label, this.value);
}

const List<PriceLine> samplePriceLines = [
  PriceLine('٣ ليالي × ١٬٤٥٠ ج.م', '٤٬٣٥٠ ج.م'),
  PriceLine('رسوم الخدمة', '١٤٩ ج.م'),
  PriceLine('العمولة', '٧٠ ج.م'),
];

const String paymentNote = 'تحويل بنكي أو كاش عند الوصول';
