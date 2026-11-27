import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/auth_repository.dart';
import '../api/role_repository.dart';
import '../format.dart';
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
  const OwnerDashboardScreen({super.key, required this.snapshot});

  final RoleSnapshot snapshot;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً ${snapshot.userName}',
                  style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
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
            children: [
              _StatCard(
                icon: Icons.apartment_rounded,
                label: 'وحدات منشورة',
                value: arabicDigits(snapshot.ownerSummary?.published ?? 0),
                color: navy,
              ),
              _StatCard(
                icon: Icons.calendar_month_rounded,
                label: 'حجوزات نشطة',
                value: arabicDigits(snapshot.ownerSummary?.activeBookings ?? 0),
                color: successGreen,
              ),
              _StatCard(
                icon: Icons.star_rounded,
                label: 'متوسط التقييم',
                value: arabicDigits(
                  (snapshot.ownerSummary?.rating ?? 0).toStringAsFixed(1).replaceFirst('.', '٫'),
                ),
                color: gold,
              ),
              _StatCard(
                icon: Icons.pending_actions_rounded,
                label: 'طلبات جديدة',
                value: arabicDigits(snapshot.ownerSummary?.newRequests ?? 0),
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
            snapshot.fromMock
                ? 'بيانات معاينة محلية — شغّل الإصدار مع الخادم لعرض بيانات حسابك.'
                : 'البيانات محدثة من خادم قيوالو.',
            style: TextStyle(color: muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OwnerUnitsScreen extends StatelessWidget {
  const OwnerUnitsScreen({super.key, required this.snapshot});

  final RoleSnapshot snapshot;

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
          Text(
            '${arabicDigits(snapshot.ownerProperties.length)} وحدات · ${arabicDigits(snapshot.ownerSummary?.published ?? 0)} منشورة',
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...snapshot.ownerProperties.map(
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
                          unit.statusAr,
                          unit.statusAr == 'منشورة' ? successGreen : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${unit.cityAr} · ${unit.price}',
                        style: const TextStyle(color: muted, fontSize: 13)),
                    Text('الحالة: ${unit.statusAr} · المرجع ${unit.id}',
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
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/owner-unit-form',
                              arguments: unit.id,
                            ),
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
  const OwnerUnitFormScreen({
    super.key,
    required this.snapshot,
    this.unitId,
  });

  final RoleSnapshot snapshot;
  final String? unitId;

  @override
  State<OwnerUnitFormScreen> createState() => _OwnerUnitFormScreenState();
}

class _OwnerUnitFormScreenState extends State<OwnerUnitFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _price;
  bool _published = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final matches = widget.snapshot.ownerProperties
        .where((property) => property.id == widget.unitId)
        .toList();
    final existing = matches.isEmpty ? null : matches.first;
    _name = TextEditingController(text: existing?.name ?? 'وحدة جديدة');
    _city = TextEditingController(text: existing?.cityAr ?? 'الأقصر');
    _price = TextEditingController(
      text: (existing?.price ?? '١٬٤٥٠ ج.م').replaceAll(' ج.م', ''),
    );
    _published = existing?.statusAr == 'منشورة';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final auth = AuthRepository();
      final token = auth.useMock ? 'preview-token' : await auth.savedToken;
      if (token == null || token.isEmpty) {
        throw const ApiException('سجّل الدخول أولاً.');
      }
      final price = int.tryParse(_price.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      await RoleRepository(useMock: auth.useMock).saveOwnerProperty(
        token: token,
        id: widget.unitId,
        name: _name.text,
        cityAr: _city.text,
        price: price,
      );
      if (!mounted) return;
      _previewNotice(
        context,
        auth.useMock ? 'تم حفظ المعاينة محلياً فقط' : 'تم حفظ الوحدة بنجاح',
      );
    } on ApiException catch (error) {
      if (mounted) _previewNotice(context, error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
          Text(
            widget.snapshot.fromMock
                ? 'معاينة محلية — الحفظ هيفضل هنا لحد ما تتصل بالخادم.'
                : 'الحفظ بيتم على خادم قيوالو، والنشر النهائي مراجعة إدارية.',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          QField(label: 'اسم الوحدة', hint: 'مثال: دار المدينة بإطلالة على النيل', controller: _name),
          QField(label: 'المدينة', hint: 'الأقصر', controller: _city),
          QField(label: 'سعر الليلة (ج.م)', hint: '١٬٤٥٠', controller: _price, keyboard: TextInputType.number),
          SwitchListTile(
            value: _published,
            onChanged: (value) => setState(() => _published = value),
            title: const Text('منشورة للضيوف'),
            subtitle: Text(_published ? 'الوحدة منشورة حالياً' : 'الوحدة مسودة حالياً'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: _saving ? 'جارٍ الحفظ...' : 'حفظ التغييرات',
            onPressed: _saving ? null : _save,
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
  const OwnerBookingsScreen({super.key, required this.snapshot});

  final RoleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'طلبات الحجز',
      bottomBar: _ownerNav(2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الحجوزات بتتأكد تلقائياً؛ الشاشة للقراءة فقط لحد ما نضيف حالة طلب يدوية.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...snapshot.ownerBookings.map(
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
                            booking.propertyName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        _StatusChip(
                          booking.status == 'CONFIRMED' ? 'مؤكد' : 'قيد الانتظار',
                          booking.status == 'CONFIRMED' ? successGreen : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InfoRow('المرجع', booking.reference),
                    InfoRow('الضيف', booking.guestName),
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
  const DriverDashboardScreen({super.key, required this.snapshot});

  final RoleSnapshot snapshot;

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  late bool _online;

  @override
  void initState() {
    super.initState();
    final vehicles = widget.snapshot.vehicles;
    _online = vehicles.isEmpty ? false : !vehicles.first.isPaused;
  }

  Future<void> _toggleOnline(bool value) async {
    final vehicles = widget.snapshot.vehicles;
    if (vehicles.isEmpty) {
      _previewNotice(context, 'أضف مركبة أولاً من شاشة المركبة.');
      return;
    }
    setState(() => _online = value);
    try {
      final auth = AuthRepository();
      final token = auth.useMock ? 'preview-token' : await auth.savedToken;
      if (token == null || token.isEmpty) {
        throw const ApiException('سجّل الدخول أولاً.');
      }
      await RoleRepository(useMock: auth.useMock).setVehiclePaused(
        token: token,
        id: vehicles.first.id,
        paused: !value,
      );
      if (!mounted) return;
      _previewNotice(
        context,
        auth.useMock
            ? 'تم تحديث حالة المعاينة محلياً'
            : value
                ? 'أنت متاح للرحلات الآن'
                : 'تم إيقاف استقبال الرحلات',
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _online = !value);
      _previewNotice(context, error.message);
    }
  }

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
                      Text(
                        'مرحباً ${widget.snapshot.userName}',
                        style: const TextStyle(color: gold, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
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
                Switch(value: _online, onChanged: _toggleOnline),
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
            children: [
              _StatCard(
                icon: Icons.route_rounded,
                label: 'رحلات اليوم',
                value: arabicDigits(widget.snapshot.driverSummary?.todayTrips ?? 0),
                color: navy,
              ),
              _StatCard(
                icon: Icons.event_available_rounded,
                label: 'رحلات قادمة',
                value: arabicDigits(widget.snapshot.driverSummary?.upcomingTrips ?? 0),
                color: successGreen,
              ),
            ],
          ),
          const SectionTitle('الرحلة القادمة'),
          widget.snapshot.trips.isEmpty
              ? Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F0F6),
                      child: Icon(Icons.event_busy_rounded, color: navy),
                    ),
                    title: const Text('لا توجد رحلات حالياً'),
                    subtitle: const Text('هتظهر الرحلات هنا لما يكون فيه حجز فيه تفاصيل نقل'),
                  ),
                )
              : Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F0F6),
                      child: Icon(widget.snapshot.trips.first.icon, color: navy),
                    ),
                    title: Text(
                      '${widget.snapshot.trips.first.from} ← ${widget.snapshot.trips.first.to}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${widget.snapshot.trips.first.time} · ${widget.snapshot.trips.first.fare}',
                    ),
                    trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/driver-trip-detail',
                      arguments: widget.snapshot.trips.first,
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
  const DriverTripsScreen({super.key, required this.snapshot});

  final RoleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'الرحلات المتاحة',
      bottomBar: _driverNav(1),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${arabicDigits(snapshot.trips.length)} رحلات · ${snapshot.fromMock ? 'بيانات معاينة محلية' : 'محدثة من خادم قيوالو'}',
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (snapshot.trips.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.event_busy_rounded, color: muted),
                title: Text('لا توجد رحلات متاحة حالياً'),
                subtitle: Text('الرحلات هتظهر هنا لما يكون فيه حجز فيه تفاصيل نقل.'),
              ),
            ),
          ...snapshot.trips.map(
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
  const DriverVehicleScreen({super.key, required this.snapshot});

  final RoleSnapshot snapshot;

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
                children: [
                  const SectionTitle('بيانات المركبة'),
                  if (snapshot.vehicles.isEmpty)
                    const InfoRow('الحالة', 'لا توجد مركبة مسجّلة بعد')
                  else ...snapshot.vehicles.map(
                    (vehicle) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow('الاسم', vehicle.name),
                        InfoRow('الطراز', vehicle.model.isEmpty ? '—' : vehicle.model),
                        InfoRow('اللوحة', vehicle.plateNumber.isEmpty ? '—' : vehicle.plateNumber),
                        InfoRow('المدينة', vehicle.cityAr),
                        InfoRow('المقاعد', arabicDigits(vehicle.capacity)),
                        InfoRow('الأجرة', money(vehicle.pricePerTrip)),
                        InfoRow(
                          'المسار',
                          '${vehicle.routeFrom} ← ${vehicle.routeTo}',
                        ),
                        InfoRow('الحالة', vehicle.statusAr),
                        InfoRow('استقبال الرحلات', vehicle.isPaused ? 'موقوف' : 'متاح'),
                        if (vehicle.blockedDates.isNotEmpty)
                          InfoRow('تواريخ محجوبة', vehicle.blockedDates.map(dateAr).join(' · ')),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const Divider(height: 22),
                  const SectionTitle('الملف والاشتراك'),
                  InfoRow('الاسم', snapshot.driverProfile?.name ?? '—'),
                  InfoRow('الهاتف', snapshot.driverProfile?.phone ?? '—'),
                  InfoRow('المدينة', snapshot.driverProfile?.cityAr ?? '—'),
                  InfoRow('الاشتراك', snapshot.driverProfile?.subscriptionAr ?? '—'),
                  InfoRow('التوثيق', snapshot.driverProfile?.verificationStatus ?? '—'),
                  if (snapshot.driverProfile != null &&
                      snapshot.driverProfile!.note.isNotEmpty)
                    InfoRow('ملاحظة', snapshot.driverProfile!.note),
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
