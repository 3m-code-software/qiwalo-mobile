import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/booking_repository.dart';
import '../data.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({
    super.key,
    this.initialReference,
    BookingRepository? repository,
  }) : repository = repository ?? const BookingRepository();

  final String? initialReference;
  final BookingRepository repository;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _reference = TextEditingController();
  MobileBooking? _booking;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialReference;
    if (initial != null && initial.isNotEmpty) {
      _reference.text = initial;
      _lookup(initial);
    }
  }

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  Future<void> _lookup(String value) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final booking = await widget.repository.lookup(value.trim());
      if (mounted) setState(() => _booking = booking);
    } catch (error) {
      if (mounted) {
        setState(() {
          _booking = null;
          _error = error is ApiException ? error.message : 'تعذّر البحث عن الحجز.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'حجوزاتي',
      navIndex: 2,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('بحث برقم الحجز'),
          TextField(
            controller: _reference,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'رقم الحجز',
              hintText: 'QW-XXXXXXXX-XXXX',
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: _loading ? 'جاري البحث...' : 'بحث عن حجز',
            onPressed: _loading ? null : () => _lookup(_reference.text),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: dangerRed, fontWeight: FontWeight.bold)),
          ],
          if (_booking != null) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/success', arguments: _booking),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(_booking!.propertyName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          StatusChip(_booking!.status == 'CONFIRMED' ? 'مؤكد' : _booking!.status, successGreen),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_booking!.reference,
                          style: const TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 6),
                      InfoRow('التواريخ', '${dateAr(_booking!.checkIn)} ← ${dateAr(_booking!.checkOut)}'),
                      InfoRow('الإجمالي', money(_booking!.total)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SectionTitle('معاينة'),
          ...sampleBookings.map((b) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/booking-detail', arguments: b),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(b.stay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            StatusChip(b.status, b.status == 'مؤكد' ? successGreen : gold),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(b.reference, style: const TextStyle(color: muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        InfoRow('التواريخ', b.dates),
                        InfoRow('الضيوف', b.guests),
                        InfoRow('الإجمالي', b.total),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          const Text('اضغط على أي حجز لعرض التفاصيل وإمكانية الإلغاء.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final booking = args is SampleBooking ? args : sampleBookings.first;
    return AppShell(
      title: 'تفاصيل الحجز',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
            child: Column(
              children: [
                InfoRow('المرجع', booking.reference),
                InfoRow('الوحدة', booking.stay),
                InfoRow('التواريخ', booking.dates),
                InfoRow('الضيوف', booking.guests),
                InfoRow('الإجمالي', booking.total),
                InfoRow('الحالة', booking.status),
                const InfoRow('الدفع', paymentNote),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SecondaryButton(
            label: 'تقييم الإقامة (بعد الاكتمال)',
            onPressed: null,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: dangerRed, side: const BorderSide(color: dangerRed)),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('إلغاء الحجز؟'),
                content: const Text('لا يتم الإلغاء إلا بعد تأكيدك.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('رجوع')),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('تأكيد الإلغاء')),
                ],
              ),
            ),
            child: const Text('إلغاء الحجز'),
          ),
          const SizedBox(height: 18),
          const Text('محتاج مساعدة؟ ٠١٠٦٦٠٩٤٠٥٠', textAlign: TextAlign.center, style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'المفضلة',
      navIndex: 1,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('الوحدات اللي حفظتها على هذا الجهاز.', style: TextStyle(color: muted)),
          const SizedBox(height: 12),
          ...sampleStays.take(2).map((stay) => StayCard(stay: stay)),
          const SizedBox(height: 8),
          SecondaryButton(label: 'ابحث عن وحدات أخرى', onPressed: () => Navigator.pushNamed(context, '/home')),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'حسابي',
      navIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(18)),
            child: const Row(
              children: [
                CircleAvatar(backgroundColor: gold, child: Icon(Icons.person_rounded, color: navy)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ضيف قيوالو', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('guest@qiwalo.test', style: TextStyle(color: Color(0xFFC7D2DF), fontSize: 12)),
                      SizedBox(height: 4),
                      StatusChip('ضيف', gold),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const InfoRow('رقم التليفون', '٠١٠٦٦٠٩٤٠٥٠'),
                SwitchListTile(
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  title: const Text('إشعارات التطبيق'),
                  subtitle: const Text('تنبيهات الحجز والتوثيق'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.telegram_rounded, color: navy),
                  title: const Text('تفعيل تليجرام'),
                  trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/telegram'),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: navy),
                  title: const Text('المساعدة والشروط'),
                  trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/help'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: dangerRed),
                  title: const Text('تسجيل الخروج', style: TextStyle(color: dangerRed)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('نسخة المعاينة · تصميم ثابت بدون API', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'المساعدة والشروط',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('تواصل مع الدعم'),
          const SupportRow(icon: Icons.chat_rounded, label: 'واتساب', value: 'https://wa.me/201066094050'),
          const SupportRow(icon: Icons.telegram_rounded, label: 'تليجرام', value: 'https://t.me/+201066094050'),
          const SupportRow(icon: Icons.call_rounded, label: 'تليفون', value: '٠١٠٦٦٠٩٤٠٥٠'),
          const SectionTitle('المستندات'),
          _doc('سياسة الخصوصية', '/privacy'),
          _doc('شروط الضيوف', '/terms/guest'),
          _doc('شروط المالكين', '/terms/owner'),
          _doc('شروط السائقين', '/terms/driver'),
          _doc('شروط المنصة', '/terms/platform'),
        ],
      ),
    );
  }

  Widget _doc(String title, String path) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(path, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.open_in_new_rounded, size: 16),
        onTap: () {},
      ),
    );
  }
}

class SupportRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const SupportRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: navy),
        title: Text(label),
        subtitle: Text(value, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.launch_rounded, size: 16),
        onTap: () {},
      ),
    );
  }
}
