import 'package:flutter/material.dart';
import '../api/booking_repository.dart';
import '../api/mock_data.dart';
import '../api/unit_repository.dart';
import '../data.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets.dart';

const String defaultUnitSlug = 'nile-view-dar-al-madina';

String _ar(Object? value) {
  const western = '0123456789';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return value.toString().replaceAllMapped(RegExp(r'[0-9]'), (match) {
    return arabic[western.indexOf(match.group(0)!)];
  });
}

String _money(Object? value) {
  final parts = value.toString().split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match.group(1)}٬',
  );
  final decimals = parts.length > 1 ? '.${_ar(parts[1])}' : '';
  return '${_ar(grouped)}$decimals ج.م';
}

/// أول يوم متاح + ٣ ليالي، كبداية واقعية لحجز من شاشة الوحدة.
BookingDraft _draftFor(UnitDetail unit, String slug) {
  final openDates = unit.availability
      .where((day) => !day.isBlocked && DateTime.tryParse(day.date) != null)
      .map((day) => day.date)
      .toList()
    ..sort();
  final checkIn = openDates.isNotEmpty
      ? openDates.first
      : isoDate(DateTime.now().add(const Duration(days: 5)));
  final parsed = DateTime.tryParse(checkIn) ?? DateTime.now();
  return BookingDraft(
    slug: slug,
    unitName: unit.name.isEmpty ? 'وحدة قيوالو' : unit.name,
    cityAr: unit.cityAr,
    checkIn: checkIn,
    checkOut: isoDate(parsed.add(const Duration(days: 3))),
    guests: 2,
    maxGuests: unit.maxGuests,
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'قيوالو',
      navIndex: 0,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('وجدتك إقامة فين؟', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _SearchBox(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('الأقصر')),
              Chip(label: Text('أسوان')),
              Chip(label: Text('كل الوحدات')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MiniCard(icon: Icons.calendar_today_rounded, title: 'الوصول', value: '٢٥ مايو ٢٠٢٧')),
              const SizedBox(width: 10),
              Expanded(child: _MiniCard(icon: Icons.calendar_month_rounded, title: 'المغادرة', value: '٢٨ مايو ٢٠٢٧')),
            ],
          ),
          const SizedBox(height: 10),
          _MiniCard(icon: Icons.people_outline_rounded, title: 'الضيوف', value: '٢ ضيف'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('وحدات مقترحة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => showFilterSheet(context),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('فلاتر'),
              ),
            ],
          ),
          ...sampleStays.map((stay) => StayCard(stay: stay)),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: navy),
          SizedBox(width: 10),
          Text('ابحث عن مدينة أو وحدة', style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _MiniCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: line)),
      child: Row(
        children: [
          Icon(icon, color: navy, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: muted, fontSize: 11)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (context) => const FilterSheet(),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double _price = 2500;
  int _type = 0;
  int _rating = 0;
  final List<bool> _amenities = [true, false, true, false];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تصفية النتائج', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const SectionTitle('السعر للليلة'),
            Slider(value: _price, min: 500, max: 4000, divisions: 7, label: '${_price.round()} ج.م', onChanged: (v) => setState(() => _price = v)),
            const SectionTitle('نوع الوحدة'),
            Wrap(
              spacing: 8,
              children: List.generate(3, (i) => ChoiceChip(
                label: Text(['الكل', 'شقة', 'فيلا'][i]),
                selected: _type == i,
                onSelected: (_) => setState(() => _type = i),
              )),
            ),
            const SectionTitle('التقييم'),
            Wrap(
              spacing: 8,
              children: List.generate(3, (i) => ChoiceChip(
                label: Text(['الكل', '٤+', '٤٫٥+'][i]),
                selected: _rating == i,
                onSelected: (_) => setState(() => _rating = i),
              )),
            ),
            const SectionTitle('المرافق'),
            Wrap(
              spacing: 8,
              children: List.generate(4, (i) => FilterChip(
                label: Text(['واي فاي', 'مكيف', 'مطبخ', 'موقف'][i]),
                selected: _amenities[i],
                onSelected: (v) => setState(() => _amenities[i] = v),
              )),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: SecondaryButton(label: 'مسح', onPressed: () => setState(() {
                  _price = 2500; _type = 0; _rating = 0;
                  for (var i = 0; i < _amenities.length; i++) { _amenities[i] = false; }
                }))),
                const SizedBox(width: 10),
                Expanded(child: PrimaryButton(label: 'عرض النتائج', onPressed: () => Navigator.pop(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UnitScreen extends StatefulWidget {
  const UnitScreen({
    super.key,
    this.slug,
    UnitRepository? repository,
  }) : repository = repository ?? const UnitRepository();

  final String? slug;
  final UnitRepository repository;

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  late final String _slug;
  late final PageController _heroController;
  UnitDetail _unit = mockUnitDetail;
  int _heroPage = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _slug = (widget.slug != null && widget.slug!.trim().isNotEmpty)
        ? widget.slug!.trim()
        : defaultUnitSlug;
    _heroController = PageController();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    try {
      final unit = await widget.repository.fetchUnit(_slug);
      if (!mounted) return;
      setState(() {
        _unit = unit;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unit = mockUnitDetail;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = _unit;
    final nightPrice = _money(unit.basePrice);

    return AppShell(
      title: 'تفاصيل الوحدة',
      bottomBar: _BookingBar(price: '$nightPrice / ليلة', draft: _draftFor(unit, _slug)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _HeroImages(
            controller: _heroController,
            images: unit.images,
            current: _heroPage,
            onPageChanged: (index) => setState(() => _heroPage = index),
            onOpenGallery: () => Navigator.pushNamed(
              context,
              '/gallery',
              arguments: unit.images,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        unit.name.isEmpty ? 'وحدة قيوالو' : unit.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.favorite_border_rounded, color: navy),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  [unit.cityAr, unit.typeAr]
                      .where((part) => part.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: gold, size: 16),
                    Text(
                      '${_ar(unit.rating)} · ${_ar(unit.reviewCount)} تقييماً',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_loading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (unit.fromMock)
                      const StatusChip('معاينة محلية', Colors.orange),
                  ],
                ),
                const SizedBox(height: 10),
                Text(unit.description, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FactChip(
                      icon: Icons.people_outline_rounded,
                      label: '${_ar(unit.maxGuests)} ضيوف',
                    ),
                    _FactChip(
                      icon: Icons.bed_outlined,
                      label: '${_ar(unit.bedrooms)} غرف نوم',
                    ),
                    _FactChip(
                      icon: Icons.bathtub_outlined,
                      label: '${_ar(unit.bathrooms)} حمامات',
                    ),
                    if (unit.areaSqm != null)
                      _FactChip(
                        icon: Icons.square_foot_rounded,
                        label: '${_ar(unit.areaSqm)} م²',
                      ),
                  ],
                ),
                const SectionTitle('المرافق'),
                if (unit.amenities.isEmpty)
                  const Text('لا توجد مرافق مسجلة لهذه الوحدة.',
                      style: TextStyle(color: muted))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: unit.amenities
                        .map((amenity) => Chip(
                              avatar: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: navy,
                              ),
                              label: Text(amenity),
                            ))
                        .toList(),
                  ),
                const SectionTitle('المضيف'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: line),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: navy,
                        child: Icon(Icons.person_outline_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('مضيف الوحدة',
                                style:
                                    TextStyle(color: muted, fontSize: 12)),
                            Text(
                              unit.host.isEmpty ? 'مضيف قيوالو' : unit.host,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('التوافر والأسعار'),
                _WeekStrip(
                  availability: unit.availability,
                  basePrice: unit.basePrice,
                ),
                TextButton.icon(
                  onPressed: () => showCalendarSheet(
                    context,
                    availability: unit.availability,
                    basePrice: unit.basePrice,
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('عرض كل التواريخ'),
                ),
                if (unit.priceRules.isNotEmpty) ...[
                  const SectionTitle('قواعد الأسعار'),
                  ...unit.priceRules.map(
                    (rule) => InfoRow(
                      rule.name,
                      '${_money(rule.price)} / ليلة · ${_ar(rule.minNights)} ليالٍ',
                    ),
                  ),
                ],
                const SectionTitle('تقييمات الضيوف'),
                if (unit.reviews.isEmpty)
                  const Text('لا توجد تقييمات منشورة بعد.',
                      style: TextStyle(color: muted))
                else
                  ...unit.reviews.take(3).map(_ReviewTile.new),
                const SectionTitle('سياسة الإلغاء والقواعد'),
                InfoRow('الإلغاء', unit.cancellation),
                if (unit.houseRules.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(unit.houseRules, style: const TextStyle(height: 1.6)),
                ],
                const SectionTitle('الدعم'),
                _ContactRow(
                  icon: Icons.call_outlined,
                  label: 'الهاتف',
                  value: unit.supportPhone,
                ),
                _ContactRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'واتساب',
                  value: unit.whatsapp,
                ),
                _ContactRow(
                  icon: Icons.send_outlined,
                  label: 'تيليجرام',
                  value: unit.telegram,
                ),
                const SectionTitle('أضف إلى إقامتك'),
                ...sampleServices.map((s) => _ServiceTile(service: s)),
                const SectionTitle('ملخص السعر'),
                PriceBox(
                  lines: [
                    PriceLine('السعر للليلة', nightPrice),
                    PriceLine('العملة', unit.currency),
                  ],
                  total: nightPrice,
                ),
                if (unit.paymentCopy.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    unit.paymentCopy,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImages extends StatelessWidget {
  const _HeroImages({
    required this.controller,
    required this.images,
    required this.current,
    required this.onPageChanged,
    required this.onOpenGallery,
  });

  final PageController controller;
  final List<String> images;
  final int current;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: images.isEmpty
                ? const PlaceholderImage(
                    label: 'لا توجد صور متاحة',
                    icon: Icons.apartment_rounded,
                    height: 210,
                  )
                : SizedBox(
                    height: 210,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: images.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) =>
                          UnitImage(url: images[index], height: 210),
                    ),
                  ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: InkWell(
              onTap: onOpenGallery,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_ar(current + 1)} / ${_ar(images.length)} · عرض الكل',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: navy),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile(this.review);

  final UnitReview review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: gold),
                const SizedBox(width: 4),
                Text(_ar(review.rating),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(_dateAr(review.createdAt),
                    style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            Text(review.guestName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(review.comment, style: const TextStyle(height: 1.5)),
            if (review.ownerReply != null &&
                review.ownerReply!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('رد المضيف: ${review.ownerReply}',
                    style: const TextStyle(height: 1.5, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 18, color: navy),
            const SizedBox(width: 8),
            Text('$label: ', style: const TextStyle(color: muted)),
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      );
}

class _BookingBar extends StatelessWidget {
  final String price;
  final BookingDraft draft;
  const _BookingBar({required this.price, required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
          color: Colors.white, border: Border(top: BorderSide(color: line))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('السعر', style: TextStyle(color: muted, fontSize: 11)),
                Text(price,
                    style: const TextStyle(
                        color: navy, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/checkout', arguments: draft),
            child: const Text('احجز الآن'),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.availability, required this.basePrice});

  final List<AvailabilityDay> availability;
  final num basePrice;

  @override
  Widget build(BuildContext context) {
    final days = availability.take(7).toList();
    if (days.isEmpty) {
      return const Text('التوافر غير متاح حالياً.', style: TextStyle(color: muted));
    }
    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          final price = day.priceOverride ?? basePrice;
          final parts = day.date.split('-');
          final dayNumber = parts.length == 3 ? parts[2] : day.date;
          final month = parts.length == 3
              ? _monthAr(int.tryParse(parts[1]) ?? 0)
              : '';
          return Container(
            width: 66,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: day.isBlocked ? const Color(0xFFEEEAE0) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: day.isBlocked ? line : navy),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month.isEmpty ? _ar(dayNumber) : '$month ${_ar(dayNumber)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(_money(price),
                    style: TextStyle(
                        fontSize: 10, color: day.isBlocked ? muted : navy)),
                if (day.isBlocked)
                  const Text('مغلق',
                      style: TextStyle(fontSize: 9, color: dangerRed)),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _monthAr(int month) {
  const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String _dateAr(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return '${_ar(date.day)}/${_ar(date.month)}/${_ar(date.year)}';
}

class _ServiceTile extends StatelessWidget {
  final ServiceOption service;
  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(service.icon, color: navy),
        title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(service.subtitle),
        trailing: Text(service.price, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

void showCalendarSheet(
  BuildContext context, {
  List<AvailabilityDay>? availability,
  num? basePrice,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (context) => CalendarSheet(
      availability: availability,
      basePrice: basePrice,
    ),
  );
}

/// معاينة ثابتة للورقة لغرض مراجعة التصميم فقط (لا تُستخدم في مسار الحجز).
class SheetPreview extends StatelessWidget {
  const SheetPreview({super.key, required this.title, required this.sheet});

  final String title;
  final Widget sheet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xAA0B2341),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: navy,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3EA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: sheet,
          ),
        ),
      ),
    );
  }
}

class CalendarSheet extends StatefulWidget {
  const CalendarSheet({super.key, this.availability, this.basePrice});

  final List<AvailabilityDay>? availability;
  final num? basePrice;

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final rows = widget.availability;
    final List<(String, String, bool)> days;
    String title = 'مايو ٢٠٢٧';

    if (rows != null && rows.isNotEmpty) {
      days = rows.take(7).map((row) {
        final parts = row.date.split('-');
        final dayNumber = parts.length == 3 ? parts[2] : row.date;
        return (
          _ar(dayNumber),
          _money(row.priceOverride ?? widget.basePrice ?? 0),
          row.isBlocked,
        );
      }).toList();
      final first = DateTime.tryParse(rows.first.date);
      if (first != null) {
        title = '${_monthAr(first.month)} ${_ar(first.year)}';
      }
    } else {
      // معاينة ثابتة لورقة التقويم في فهرس التصميم فقط.
      days = const [
        ('٢٥', '١٬٤٥٠', false), ('٢٦', '١٬٤٥٠', false),
        ('٢٧', '١٬٥٢٠', true), ('٢٨', '١٬٤٥٠', false),
        ('٢٩', '١٬٤٥٠', false), ('٣٠', '١٬٦٠٠', true),
        ('٣١', '١٬٤٥٠', false),
      ];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.85),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              return InkWell(
                onTap: day.$3 ? null : () => setState(() => _selected = i),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _selected == i ? navy : (day.$3 ? const Color(0xFFEEEAE0) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.$1, style: TextStyle(color: _selected == i ? Colors.white : ink, fontWeight: FontWeight.bold)),
                      Text(day.$2, style: TextStyle(fontSize: 8, color: _selected == i ? Colors.white : muted)),
                      if (day.$3) const Icon(Icons.block_rounded, size: 10, color: dangerRed),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block_rounded, size: 14, color: dangerRed),
              Text(' يوم مغلق', style: TextStyle(fontSize: 12)),
              SizedBox(width: 16),
              Icon(Icons.check_circle_rounded, size: 14, color: successGreen),
              Text(' متاح', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: days.isEmpty
                ? 'تم'
                : 'تم · وصول ${days.first.$1} ← مغادرة ${days.last.$1}',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.images});

  final List<String>? images;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final controller = PageController();
  int current = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images ?? const <String>[];
    final count = images.isEmpty ? 3 : images.length;
    final icons = [Icons.apartment_rounded, Icons.bed_rounded, Icons.balcony_rounded];
    final labels = ['الواجهة', 'غرفة النوم', 'التراس'];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${_ar(current + 1)} / ${_ar(count)}'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: count,
              onPageChanged: (i) => setState(() => current = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.all(16),
                child: images.isEmpty
                    ? PlaceholderImage(
                        label: labels[i % labels.length],
                        icon: icons[i % icons.length],
                        height: double.infinity,
                        color: navyLight,
                      )
                    : UnitImage(url: images[i], height: double.infinity),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              images.isEmpty ? labels[current % labels.length] : 'صورة ${_ar(current + 1)}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
