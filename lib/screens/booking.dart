import 'package:flutter/material.dart';

import '../api/booking_repository.dart';
import '../api/api_client.dart';
import '../data.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets.dart';

/// الحجز من شاشة الوحدة لحد رقم المرجع الحقيقي — كل الأسعار والتحقق من الخادم.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.draft,
    BookingRepository? repository,
  }) : repository = repository ?? const BookingRepository();

  final BookingDraft draft;
  final BookingRepository repository;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _nationality = TextEditingController(text: 'مصرية');

  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _guests;
  late final String _idempotencyKey;

  String _paymentMethod = 'CASH';
  bool _terms = false;
  BookingQuote? _quote;
  String? _quoteError;
  String? _submitError;
  bool _loadingQuote = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _checkIn = DateTime.tryParse(widget.draft.checkIn) ??
        DateTime.now().add(const Duration(days: 5));
    _checkOut = DateTime.tryParse(widget.draft.checkOut) ??
        _checkIn.add(const Duration(days: 3));
    if (!_checkOut.isAfter(_checkIn)) {
      _checkOut = _checkIn.add(const Duration(days: 3));
    }
    _guests = widget.draft.guests.clamp(1, widget.draft.maxGuests < 1 ? 1 : widget.draft.maxGuests);
    _idempotencyKey = BookingRepository.newIdempotencyKey();
    _loadQuote();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _nationality.dispose();
    super.dispose();
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loadingQuote = true;
      _quoteError = null;
    });
    try {
      final quote = await widget.repository.quote(
        slug: widget.draft.slug,
        checkIn: isoDate(_checkIn),
        checkOut: isoDate(_checkOut),
        guests: _guests,
      );
      if (mounted) setState(() => _quote = quote);
    } catch (error) {
      if (mounted) {
        setState(() => _quoteError = error is ApiException ? error.message : 'تعذّر حساب السعر.');
      }
    } finally {
      if (mounted) setState(() => _loadingQuote = false);
    }
  }

  Future<void> _pickDate({required bool checkIn}) async {
    final now = DateTime.now();
    final initial = checkIn ? _checkIn : _checkOut;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar', 'EG'),
    );
    if (picked == null) return;
    setState(() {
      if (checkIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        if (picked.isAfter(_checkIn)) _checkOut = picked;
      }
    });
    await _loadQuote();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim().toLowerCase();
    final phone = _phone.text.replaceAll(RegExp(r'\D'), '');
    final message = name.isEmpty
        ? 'أدخل الاسم الكامل.'
        : !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)
            ? 'أدخل بريداً إلكترونياً صحيحاً.'
            : !RegExp(r'^01\d{9}$').hasMatch(phone)
                ? 'أدخل رقم هاتف مصري صحيح يبدأ بـ ٠١.'
                : _nationality.text.trim().isEmpty
                    ? 'أدخل الجنسية.'
                    : !_terms
                        ? 'لازم توافق على شروط الحجز.'
                        : _quote == null
                            ? 'لازم يتحسب السعر قبل التأكيد.'
                            : null;
    if (message != null) {
      setState(() => _submitError = message);
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final booking = await widget.repository.confirm(
        draft: widget.draft.copyWith(
          checkIn: isoDate(_checkIn),
          checkOut: isoDate(_checkOut),
          guests: _guests,
        ),
        fullName: name,
        email: email,
        phone: phone,
        nationality: _nationality.text.trim(),
        paymentMethod: _paymentMethod,
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/success', arguments: booking);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = error is ApiException ? error.message : 'تعذّر تأكيد الحجز. حاول مرة تانية.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<PriceLine> _priceLines() {
    final quote = _quote;
    if (quote == null) return const [];
    final lines = quote.nightly
        .map((night) => PriceLine(
              '${dateAr(night.date)} · ${money(night.price)}',
              money(night.price),
            ))
        .toList();
    if (quote.serviceFee > 0) {
      lines.add(PriceLine('رسوم الخدمة', money(quote.serviceFee)));
    }
    for (final addOn in quote.addOns) {
      lines.add(PriceLine(addOn.label, money(addOn.amount)));
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return AppShell(
      title: 'تأكيد الحجز',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle('بيانات الضيف'),
          QField(label: 'الاسم الكامل', hint: 'مثال: أحمد محمد', controller: _name),
          QField(
            label: 'الإيميل',
            hint: 'name@example.com',
            keyboard: TextInputType.emailAddress,
            controller: _email,
          ),
          QField(
            label: 'رقم التليفون',
            hint: '01xxxxxxxxx',
            keyboard: TextInputType.phone,
            controller: _phone,
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextField(
              controller: _nationality,
              decoration: const InputDecoration(labelText: 'الجنسية'),
            ),
          ),
          const SectionTitle('التوافر والضيوف'),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'الوصول',
                  value: dateAr(isoDate(_checkIn)),
                  onTap: () => _pickDate(checkIn: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTile(
                  label: 'المغادرة',
                  value: dateAr(isoDate(_checkOut)),
                  onTap: () => _pickDate(checkIn: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('عدد الضيوف', style: TextStyle(color: muted)),
              const Spacer(),
              DropdownButton<int>(
                value: _guests,
                items: List.generate(
                  draft.maxGuests < 1 ? 1 : draft.maxGuests,
                  (i) => DropdownMenuItem(value: i + 1, child: Text(arabicDigits(i + 1))),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _guests = value);
                  _loadQuote();
                },
              ),
            ],
          ),
          const SectionTitle('طريقة الدفع'),
          _PaymentOption(
            selected: _paymentMethod == 'CASH',
            icon: Icons.money_rounded,
            title: 'كاش عند الوصول',
            onTap: () => setState(() => _paymentMethod = 'CASH'),
          ),
          _PaymentOption(
            selected: _paymentMethod == 'BANK',
            icon: Icons.account_balance_rounded,
            title: 'تحويل بنكي',
            onTap: () => setState(() => _paymentMethod = 'BANK'),
          ),
          Row(
            children: [
              Checkbox(value: _terms, onChanged: (value) => setState(() => _terms = value ?? false)),
              const Expanded(child: Text('أوافق على شروط الحجز والإلغاء')),
            ],
          ),
          const SectionTitle('ملخص الحجز'),
          InfoRow('الوحدة', draft.unitName),
          InfoRow('المدينة', draft.cityAr),
          InfoRow('الليالي', arabicDigits(_quote?.nights ?? '')),
          const SizedBox(height: 12),
          if (_loadingQuote)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_quoteError != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dangerRed),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_quoteError!, textAlign: TextAlign.center, style: const TextStyle(color: dangerRed)),
                  const SizedBox(height: 10),
                  SecondaryButton(label: 'إعادة المحاولة', onPressed: _loadQuote),
                ],
              ),
            )
          else if (_quote != null) ...[
            PriceBox(lines: _priceLines(), total: money(_quote!.grandTotal)),
            if (_quote!.fromMock)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'معاينة محلية — الأسعار المعروضة للعرض فقط.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: dangerRed, fontSize: 12),
                ),
              ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _quote?.paymentCopy ?? 'تحويل بنكي أو كاش عند الوصول',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 14),
            Text(
              _submitError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: dangerRed, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 18),
          PrimaryButton(
            label: _submitting ? 'جاري التأكيد...' : 'تأكيد الحجز',
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: 10),
          const Text(
            'رقم التليفون مستخدم بحساب آخر؟ هيظهر تنبيه واضح قبل إتمام الحجز.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: navy, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: muted, fontSize: 11)),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? navy : line, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(icon, color: navy),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: navy,
                ),
              ],
            ),
          ),
        ),
      );
}

/// شاشة النجاح تعرض رقم الحجز الحقيقي وحالته كما رجع من BFF.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final MobileBooking booking;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'تم الحجز',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            backgroundColor: successGreen,
            radius: 46,
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(height: 20),
          Text(
            booking.fromMock ? 'معاينة محلية للحجز' : 'تم تأكيد حجزك!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            booking.fromMock
                ? 'لم يتم إنشاء حجز حقيقي في هذا الوضع.'
                : 'هوصلك إشعار بالتفاصيل، والدفع كما اخترت.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: line),
            ),
            child: Column(
              children: [
                InfoRow('رقم الحجز', booking.reference),
                InfoRow('الوحدة', booking.propertyName),
                InfoRow('المدينة', booking.cityAr),
                InfoRow('التواريخ', '${dateAr(booking.checkIn)} ← ${dateAr(booking.checkOut)}'),
                InfoRow('الإجمالي', money(booking.total)),
                InfoRow('الحالة', _statusAr(booking.status)),
                InfoRow('الدفع', _paymentAr(booking.paymentMethod)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(booking.paymentCopy, textAlign: TextAlign.center, style: const TextStyle(color: muted)),
          const SizedBox(height: 10),
          Text(
            'الدعم: ${booking.support.phone}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'اعرض حجوزاتي',
            onPressed: () => Navigator.pushNamed(context, '/bookings', arguments: booking.reference),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'الرئيسية',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
          ),
        ],
      ),
    );
  }
}

String _statusAr(String status) {
  switch (status) {
    case 'CONFIRMED':
      return 'مؤكد';
    case 'COMPLETED':
      return 'مكتمل';
    case 'CANCELLED':
      return 'ملغي';
    default:
      return status;
  }
}

String _paymentAr(String method) =>
    method == 'BANK' ? 'تحويل بنكي' : 'كاش عند الوصول';

/// معاينة ثابتة لطريقة الدفع في فهرس التصميم فقط — الحجز الحقيقي داخل CheckoutScreen.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'طريقة الدفع',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'اختر طريقة الدفع المناسبة لك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _PreviewOption(icon: Icons.money_rounded, title: 'كاش عند الوصول', subtitle: 'ادفع للمالك عند تسليم الوحدة'),
          _PreviewOption(icon: Icons.account_balance_rounded, title: 'تحويل بنكي', subtitle: 'حوّل قبل الوصول وأرسل الإيصال للدعم'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: line)),
            child: const Text(
              'تحويل بنكي أو كاش عند الوصول',
              textAlign: TextAlign.center,
              style: TextStyle(color: navy, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ما فيش أي بيانات بطاقة أو بوابة دفع في التطبيق.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PreviewOption extends StatelessWidget {
  const _PreviewOption({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              Icon(icon, color: navy, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
