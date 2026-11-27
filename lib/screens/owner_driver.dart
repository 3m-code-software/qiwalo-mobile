import 'package:flutter/material.dart';

import '../owner_driver_data.dart';
import '../theme.dart';
import '../widgets.dart';

class RoleNavItem {
  const RoleNavItem(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;
}

class RoleBottomNav extends StatelessWidget {
  const RoleBottomNav({
    super.key,
    required this.current,
    required this.items,
  });

  final int current;
  final List<RoleNavItem> items;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: navy,
      unselectedItemColor: muted,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
      onTap: (index) => Navigator.pushReplacementNamed(context, items[index].route),
    );
  }
}

RoleBottomNav _ownerNav(int current) => RoleBottomNav(
      current: current,
      items: const [
        RoleNavItem(Icons.dashboard_rounded, 'اللوحة', '/owner-dashboard'),
        RoleNavItem(Icons.apartment_rounded, 'وحداتي', '/owner-units'),
        RoleNavItem(Icons.event_note_rounded, 'الطلبات', '/owner-bookings'),
        RoleNavItem(Icons.person_rounded, 'حسابي', '/profile'),
      ],
    );

RoleBottomNav _driverNav(int current) => RoleBottomNav(
      current: current,
      items: const [
        RoleNavItem(Icons.dashboard_rounded, 'اللوحة', '/driver-dashboard'),
        RoleNavItem(Icons.route_rounded, 'الرحلات', '/driver-trips'),
        RoleNavItem(Icons.directions_car_rounded, 'المركبة', '/driver-vehicle'),
        RoleNavItem(Icons.person_rounded, 'حسابي', '/profile'),
      ],
    );

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            foregroundColor: color,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: navy.withValues(alpha: 0.08),
            foregroundColor: navy,
            child: Icon(icon),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          onTap: () => Navigator.pushNamed(context, route),
        ),
      );
}

void _previewNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'لوحة المالك',
      bottomBar: _ownerNav(0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً محمد',
                  style: TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'وحداتك وطلبات الحجز في مكان واحد',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: const [
              _StatCard(
                icon: Icons.apartment_rounded,
                label: 'وحدات منشورة',
                value: '٢',
                color: navy,
              ),
              _StatCard(
                icon: Icons.calendar_month_rounded,
                label: 'حجوزات نشطة',
                value: '٥',
                color: successGreen,
              ),
              _StatCard(
                icon: Icons.star_rounded,
                label: 'متوسط التقييم',
                value: '٤٫٨',
                color: gold,
              ),
              _StatCard(
                icon: Icons.pending_actions_rounded,
                label: 'طلبات جديدة',
                value: '١',
                color: Colors.orange,
              ),
            ],
          ),
          const SectionTitle('وصول سريع'),
          const _QuickAction(
            icon: Icons.apartment_rounded,
            title: 'وحداتي',
            subtitle: 'راجع الوحدات المنشورة والمسودات',
            route: '/owner-units',
          ),
          const _QuickAction(
            icon: Icons.event_note_rounded,
            title: 'طلبات الحجز',
            subtitle: 'قبول أو رفض الطلبات الجديدة',
            route: '/owner-bookings',
          ),
          const SizedBox(height: 8),
          Text(
            'هذه الشاشة معاينة محلية؛ الربط بحساب المالك بيجي في خطوة لاحقة.',
            style: TextStyle(color: muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OwnerUnitsScreen extends StatelessWidget {
  const OwnerUnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'وحداتي',
      bottomBar: _ownerNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/owner-unit-form'),
        tooltip: 'إضافة وحدة',
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '٣ وحدات · ٢ منشورة و١ مسودة',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...ownerUnits.map(
            (unit) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        _StatusChip(
                          unit.status,
                          unit.status == 'منشورة' ? successGreen : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${unit.city} · ${unit.price}',
                        style: const TextStyle(color: muted, fontSize: 13)),
                    Text('الإشغال: ${unit.occupancy}',
                        style: const TextStyle(color: muted, fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, '/calendar'),
                            child: const Text('التوافر'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/owner-unit-form'),
                            child: const Text('تعديل'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerUnitFormScreen extends StatefulWidget {
  const OwnerUnitFormScreen({super.key});

  @override
  State<OwnerUnitFormScreen> createState() => _OwnerUnitFormScreenState();
}

class _OwnerUnitFormScreenState extends State<OwnerUnitFormScreen> {
  final _name = TextEditingController(text: 'دار المدينة بإطلالة على النيل');
  final _city = TextEditingController(text: 'الأقصر');
  final _price = TextEditingController(text: '١٬٤٥٠');
  bool _published = true;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'إضافة / تعديل وحدة',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'معاينة محلية — الحفظ الحقيقي هيتم عبر BFF المالك في خطوة لاحقة.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          QField(label: 'اسم الوحدة', hint: 'مثال: دار المدينة بإطلالة على النيل', controller: _name),
          QField(label: 'المدينة', hint: 'الأقصر', controller: _city),
          QField(label: 'سعر الليلة (ج.م)', hint: '١٬٤٥٠', controller: _price, keyboard: TextInputType.number),
          SwitchListTile(
            value: _published,
            onChanged: (value) => setState(() => _published = value),
            title: const Text('منشورة للضيوف'),
            subtitle: Text(_published ? 'الوحدة ظاهرة في البحث' : 'الوحدة مسودة'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'حفظ التغييرات (معاينة)',
            onPressed: () => _previewNotice(context, 'تم حفظ المعاينة محلياً فقط'),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'إدارة التوافر',
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
          ),
        ],
      ),
    );
  }
}

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'طلبات الحجز',
      bottomBar: _ownerNav(2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'طلبات محلية للمراجعة — القرار النهائي هيتم على الخادم.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...ownerBookings.map(
            (booking) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.stay,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        _StatusChip(
                          booking.status,
                          booking.status == 'مؤكد' ? successGreen : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InfoRow('المرجع', booking.reference),
                    InfoRow('الضيف', booking.guest),
                    InfoRow('التواريخ', booking.dates),
                    InfoRow('الإجمالي', booking.total),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _previewNotice(context, 'تم رفض الطلب في المعاينة'),
                            child: const Text('رفض'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _previewNotice(context, 'تم قبول الطلب في المعاينة'),
                            child: const Text('قبول'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _online = true;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'لوحة السائق',
      bottomBar: _driverNav(0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _online ? successGreen : muted,
                  child: const Icon(Icons.directions_car_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حالة السائق',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _online ? 'متاح للرحلات' : 'غير متاح',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: const [
              _StatCard(
                icon: Icons.route_rounded,
                label: 'رحلات اليوم',
                value: '٣',
                color: navy,
              ),
              _StatCard(
                icon: Icons.star_rounded,
                label: 'التقييم',
                value: '٤٫٩',
                color: gold,
              ),
            ],
          ),
          const SectionTitle('الرحلة القادمة'),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F0F6),
                child: Icon(Icons.flight_takeoff_rounded, color: navy),
              ),
              title: const Text('مطار الأقصر ← دار المدينة', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('اليوم · ٦:٣٠ م · ٣٢٠ ج.م'),
              trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              onTap: () => Navigator.pushNamed(
                context,
                '/driver-trip-detail',
                arguments: driverTrips.first,
              ),
            ),
          ),
          const _QuickAction(
            icon: Icons.route_rounded,
            title: 'الرحلات المتاحة',
            subtitle: 'استعرض الرحلات القريبة واقبلها',
            route: '/driver-trips',
          ),
          const _QuickAction(
            icon: Icons.directions_car_rounded,
            title: 'المركبة والملف',
            subtitle: 'بيانات السيارة والمستندات',
            route: '/driver-vehicle',
          ),
        ],
      ),
    );
  }
}

class DriverTripsScreen extends StatelessWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'الرحلات المتاحة',
      bottomBar: _driverNav(1),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '٣ رحلات قريبة · البيانات محلية للمراجعة',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...driverTrips.map(
            (trip) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: navy.withValues(alpha: 0.08),
                          foregroundColor: navy,
                          child: Icon(trip.icon),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${trip.from} ← ${trip.to}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InfoRow('رقم الرحلة', trip.id),
                    InfoRow('الموعد', trip.time),
                    InfoRow('المسافة', trip.distance),
                    InfoRow('الركاب', trip.passengers),
                    InfoRow('الأجرة', trip.fare),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/driver-trip-detail',
                              arguments: trip,
                            ),
                            child: const Text('التفاصيل'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _previewNotice(context, 'تم قبول الرحلة في المعاينة'),
                            child: const Text('قبول'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverTripDetailScreen extends StatelessWidget {
  const DriverTripDetailScreen({super.key, required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'تفاصيل الرحلة',
      bottomBar: _driverNav(2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlaceholderImage(
            label: 'مسار الرحلة',
            icon: Icons.route_rounded,
            height: 150,
            color: navy,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.from} ← ${trip.to}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 10),
                  InfoRow('رقم الرحلة', trip.id),
                  InfoRow('الموعد', trip.time),
                  InfoRow('المسافة', trip.distance),
                  InfoRow('الركاب', trip.passengers),
                  InfoRow('الأجرة', trip.fare),
                  const Divider(height: 22),
                  const Text(
                    'التأكيد النهائي وتتبع الرحلة هيتمان في خطوة لاحقة عبر BFF السائق.',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'قبول الرحلة (معاينة)',
            onPressed: () => _previewNotice(context, 'تم قبول الرحلة في المعاينة'),
          ),
        ],
      ),
    );
  }
}

class DriverVehicleScreen extends StatelessWidget {
  const DriverVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'المركبة والملف',
      bottomBar: _driverNav(2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlaceholderImage(
            label: 'سيارة السائق',
            icon: Icons.directions_car_rounded,
            height: 150,
            color: navyLight,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SectionTitle('بيانات المركبة'),
                  InfoRow('الطراز', 'تويوتا كامري ٢٠٢٢'),
                  InfoRow('اللوحة', 'ق م ١٢٣٤'),
                  InfoRow('اللون', 'أبيض'),
                  InfoRow('المقاعد', '٤'),
                  Divider(height: 22),
                  SectionTitle('حالة المستندات'),
                  CheckboxListTile(
                    value: true,
                    onChanged: null,
                    title: Text('رخصة القيادة'),
                    subtitle: Text('سارية حتى ٢٠٢٨'),
                  ),
                  CheckboxListTile(
                    value: true,
                    onChanged: null,
                    title: Text('التأمين'),
                    subtitle: Text('ساري حتى ١٢/٢٠٢٦'),
                  ),
                  CheckboxListTile(
                    value: false,
                    onChanged: null,
                    title: Text('صورة المركبة'),
                    subtitle: Text('مطلوبة'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'تحديث المستندات (معاينة)',
            onPressed: () => _previewNotice(context, 'تحديث المستندات معاينة فقط'),
          ),
        ],
      ),
    );
  }
}
