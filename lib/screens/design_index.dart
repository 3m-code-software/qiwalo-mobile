import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class _Entry {
  const _Entry(this.route, this.title, this.icon);
  final String route;
  final String title;
  final IconData icon;
}

const List<_Entry> _entries = [
  _Entry('/onboarding', '١ · الترحيب', Icons.auto_stories_rounded),
  _Entry('/login', '٢ · الدخول', Icons.login_rounded),
  _Entry('/signup', '٣ · إنشاء حساب', Icons.person_add_rounded),
  _Entry('/telegram', '٤ · تفعيل تليجرام', Icons.telegram_rounded),
  _Entry('/recovery', '٥ · استعادة الباسورد', Icons.key_rounded),
  _Entry('/home', '٦ · الرئيسية والبحث', Icons.home_rounded),
  _Entry('/unit', '٧ · صفحة الوحدة', Icons.apartment_rounded),
  _Entry('/gallery', '٨ · معرض الصور', Icons.photo_library_rounded),
  _Entry('/checkout', '٩ · بيانات الضيف', Icons.assignment_rounded),
  _Entry('/payment', '١٠ · طريقة الدفع', Icons.payments_rounded),
  _Entry('/success', '١١ · نجاح الحجز', Icons.check_circle_rounded),
  _Entry('/bookings', '١٢ · حجوزاتي', Icons.receipt_long_rounded),
  _Entry('/booking-detail', '١٣ · تفاصيل الحجز', Icons.description_rounded),
  _Entry('/favorites', '١٤ · المفضلة', Icons.favorite_rounded),
  _Entry('/profile', '١٥ · الملف الشخصي', Icons.person_rounded),
  _Entry('/help', '١٦ · المساعدة والشروط', Icons.help_center_rounded),
  _Entry('/owner-dashboard', '١٧ · لوحة المالك', Icons.dashboard_rounded),
  _Entry('/owner-units', '١٨ · وحداتي', Icons.apartment_rounded),
  _Entry('/owner-unit-form', '١٩ · إضافة/تعديل وحدة', Icons.edit_location_alt_rounded),
  _Entry('/owner-bookings', '٢٠ · طلبات الحجز', Icons.event_note_rounded),
  _Entry('/driver-dashboard', '٢١ · لوحة السائق', Icons.local_taxi_rounded),
  _Entry('/driver-trips', '٢٢ · الرحلات المتاحة', Icons.route_rounded),
  _Entry('/driver-trip-detail', '٢٣ · تفاصيل الرحلة', Icons.map_rounded),
  _Entry('/driver-vehicle', '٢٤ · المركبة والملف', Icons.directions_car_rounded),
  _Entry('/contact', '٢٥ · التواصل الداخلي', Icons.support_agent_rounded),
];

class DesignIndexScreen extends StatelessWidget {
  const DesignIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'كل الشاشات · ٢٥',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
            child: const Text(
              'معاينة للشكل وتجربة المستخدم. صفحة الوحدة والحجز وشاشات المالك والسائق (١٧–٢٤) بيقروا بيانات حقيقية من BFF بعد تسجيل الدخول للأدوار. نسخة محلية معلَّمة تظهر لو الخادم مش متاح في صفحة الوحدة.',
              style: TextStyle(color: ink, height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          const Text('ورقتان إضافيتان: فلاتر البحث – تقويم التوافر (من داخل الشاشات ٦ و٧).', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: _entries
                .map((entry) => InkWell(
                      onTap: () => Navigator.pushNamed(context, entry.route),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: line)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(entry.icon, color: navy, size: 26),
                            const SizedBox(height: 8),
                            Text(entry.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
