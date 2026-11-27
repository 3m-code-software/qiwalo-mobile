const String _westernDigits = '0123456789';
const String _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

/// أرقام عربية مع فواصل الآلاف — نفس شكل الأسعار في الويب.
String arabicDigits(Object? value) => value.toString().replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _arabicDigits[_westernDigits.indexOf(match.group(0)!)],
    );

String money(Object? value) {
  final parts = value.toString().split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match.group(1)}٬',
  );
  final decimals = parts.length > 1 ? '.${arabicDigits(parts[1])}' : '';
  return '${arabicDigits(grouped)}$decimals ج.م';
}

/// yyyy-MM-dd → d/m/yyyy بالأرقام العربية.
String dateAr(String value) {
  final parts = value.split('-');
  if (parts.length != 3) return arabicDigits(value);
  return '${arabicDigits(parts[2])}/${arabicDigits(parts[1])}/${arabicDigits(parts[0])}';
}

String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
