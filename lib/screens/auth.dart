import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // حركة هادية وسلسة عشان التطبيق يبان حيّ من غير ما يبعد عن راحة البصر.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _WelcomeBackdropPainter(_controller.value),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    backgroundColor: gold,
                    radius: 38,
                    child: const Text(
                      'ق',
                      style: TextStyle(color: navy, fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'قيوالو',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'إقامتك وتجاربك في الأقصر وأسوان',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: gold, fontSize: 16),
                  ),
                  const SizedBox(height: 36),
                  _feature(
                    Icons.search_rounded,
                    'ابحث',
                    'وحدات بأسعار واضحة وتوافر محدّث',
                    () => Navigator.pushNamed(context, '/home'),
                  ),
                  _feature(
                    Icons.terrain_rounded,
                    'خطّط',
                    'سفاري ونقل وباقات في مكان واحد',
                    () => Navigator.pushNamed(context, '/home'),
                  ),
                  _feature(
                    Icons.support_agent_rounded,
                    'تواصل',
                    'دعم عربي على مدار اليوم',
                    () => Navigator.pushNamed(context, '/contact'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: navy),
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text('ابدأ الآن'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('عندي حساب · دخول', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/design'),
                    child: const Text(
                      'معاينة كل الشاشات',
                      style: TextStyle(color: Color(0xFFC7D2DF), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: navyLight, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFC7D2DF))),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 15),
          ],
        ),
      ),
    );
  }
}

/// خلفية متحركة: توهّج خفيف + جزيئات ذهبية صاعدة + موجتان بيتحركوا ببطء،
/// إشارة بصرية إن التطبيق شغّال وحّي من غير صوت أو استهلاك واضح للبطارية.
class _WelcomeBackdropPainter extends CustomPainter {
  const _WelcomeBackdropPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = value * math.pi * 2;

    _glow(
      canvas,
      center: Offset(
        size.width * (0.24 + 0.05 * math.sin(phase)),
        size.height * (0.22 + 0.03 * math.cos(phase)),
      ),
      radius: size.width * 0.62,
      color: gold.withValues(alpha: 0.13),
    );
    _glow(
      canvas,
      center: Offset(
        size.width * (0.82 + 0.04 * math.cos(phase * 0.8)),
        size.height * (0.74 + 0.04 * math.sin(phase * 0.6)),
      ),
      radius: size.width * 0.55,
      color: const Color(0xFF2E6C8E).withValues(alpha: 0.22),
    );

    for (var i = 0; i < 9; i++) {
      final progress = (value + i / 9) % 1;
      final x = size.width * (0.08 + 0.84 * ((i * 37) % 100) / 100);
      final y = size.height * (1.06 - progress * 1.2);
      final radius = 1.6 + (i % 3) * 1.1;
      final alpha = 0.08 + 0.30 * math.sin(progress * math.pi);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = gold.withValues(alpha: alpha),
      );
    }

    _wave(
      canvas,
      size,
      phase: phase,
      baseY: size.height * 0.78,
      amplitude: 16,
      waveLength: size.width * 0.75,
      color: navyLight.withValues(alpha: 0.55),
    );
    _wave(
      canvas,
      size,
      phase: phase * 1.35 + 1.2,
      baseY: size.height * 0.88,
      amplitude: 11,
      waveLength: size.width * 0.55,
      color: gold.withValues(alpha: 0.16),
    );
  }

  void _glow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _wave(
    Canvas canvas,
    Size size, {
    required double phase,
    required double baseY,
    required double amplitude,
    required double waveLength,
    required Color color,
  }) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width + 6; x += 6) {
      final y = baseY + math.sin((x / waveLength) * math.pi * 2 + phase) * amplitude;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WelcomeBackdropPainter oldDelegate) =>
      oldDelegate.value != value;
}

int passwordStrengthScore(String value) {
  if (value.isEmpty) return 0;
  var score = 0;
  if (value.length >= 8) score++;
  if (value.length >= 12) score++;
  if (value.contains(RegExp(r'[A-Za-z]'))) score++;
  if (value.contains(RegExp(r'[0-9]'))) score++;
  if (value.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
  return score > 4 ? 4 : score;
}

String passwordStrengthLabel(String value) => switch (passwordStrengthScore(value)) {
      0 => 'اكتب كلمة مرور',
      1 => 'ضعيفة',
      2 => 'متوسطة',
      3 => 'جيدة',
      _ => 'قوية',
    };

Color passwordStrengthColor(String value) => switch (passwordStrengthScore(value)) {
      0 => muted,
      1 => dangerRed,
      2 => Colors.orange,
      3 => gold,
      _ => successGreen,
    };

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _identifierHelper {
    final value = _identifierController.text.trim();
    if (value.isEmpty) {
      return 'استخدم الإيميل أو رقم التليفون اللي سجّلت بيه';
    }
    if (value.contains('@')) return 'تم التعرف على إيميل';
    return 'تم التعرف على رقم تليفون';
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    return AppShell(
      title: 'تسجيل الدخول',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PlaceholderImage(label: 'قيوالو', icon: Icons.login_rounded, height: 110),
          const SizedBox(height: 20),
          TextField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'الإيميل أو رقم التليفون',
              hintText: 'name@example.com أو 01xxxxxxxxx',
              helperText: _identifierHelper,
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'الباسورد',
              hintText: '••••••••',
              helperText: 'قوة كلمة المرور: ${passwordStrengthLabel(password)}',
              helperStyle: TextStyle(color: passwordStrengthColor(password)),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                tooltip: _obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: passwordStrengthScore(password) / 4,
            backgroundColor: line,
            color: passwordStrengthColor(password),
            minHeight: 4,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/recovery'),
              child: const Text('نسيت الباسورد؟'),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'دخول', onPressed: () => Navigator.pushNamed(context, '/home')),
          const SizedBox(height: 14),
          SecondaryButton(label: 'إنشاء حساب جديد', onPressed: () => Navigator.pushNamed(context, '/signup')),
        ],
      ),
    );
  }
}

class _DialCode {
  const _DialCode(this.country, this.label, this.dial);

  final String country;
  final String label;
  final String dial;
}

const List<_DialCode> _dialCodes = [
  _DialCode('EG', 'مصر +20', '+20'),
  _DialCode('SA', 'السعودية +966', '+966'),
  _DialCode('AE', 'الإمارات +971', '+971'),
  _DialCode('KW', 'الكويت +965', '+965'),
  _DialCode('QA', 'قطر +974', '+974'),
  _DialCode('BH', 'البحرين +973', '+973'),
  _DialCode('OM', 'عُمان +968', '+968'),
  _DialCode('JO', 'الأردن +962', '+962'),
  _DialCode('LB', 'لبنان +961', '+961'),
  _DialCode('MA', 'المغرب +212', '+212'),
  _DialCode('DZ', 'الجزائر +213', '+213'),
  _DialCode('TN', 'تونس +216', '+216'),
  _DialCode('IQ', 'العراق +964', '+964'),
  _DialCode('TR', 'تركيا +90', '+90'),
  _DialCode('US', 'أمريكا +1', '+1'),
  _DialCode('GB', 'بريطانيا +44', '+44'),
  _DialCode('DE', 'ألمانيا +49', '+49'),
  _DialCode('FR', 'فرنسا +33', '+33'),
];

String _dialCodeFromDeviceLocale() {
  final country = WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  if (country != null) {
    for (final option in _dialCodes) {
      if (option.country == country) return option.dial;
    }
  }
  // التطبيق موجه أساساً لمصر؛ ده الـ fallback لو المنطقة مش معروفة.
  return '+20';
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String _dialCode;
  bool _obscurePassword = true;
  bool _agreed = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dialCode = _dialCodeFromDeviceLocale();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  int get _passwordScore => passwordStrengthScore(_passwordController.text);

  String get _passwordLabel => passwordStrengthLabel(_passwordController.text);

  Color get _passwordColor => passwordStrengthColor(_passwordController.text);

  void _showTerms() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Text(
                'الشروط والأحكام',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                children: const [
                  _TermSection(
                    title: '١ · الحجز والتأكيد',
                    body: 'الحجز يتأكد تلقائياً بعد إدخال بيانات الضيف. رقم التليفون إلزامي، وحساب واحد فقط لكل رقم.',
                  ),
                  _TermSection(
                    title: '٢ · الدفع',
                    body: 'تحويل بنكي أو كاش عند الوصول. مش بنطلب بيانات بطاقة داخل التطبيق.',
                  ),
                  _TermSection(
                    title: '٣ · الخصوصية',
                    body: 'بياناتك بتُستخدم لتأكيد الحجز والتواصل معك بس، ومش بتتشارك مع أطراف تانية غير مقدم الخدمة.',
                  ),
                  _TermSection(
                    title: '٤ · الدعم',
                    body: 'الدعم متاح عبر واتساب أو تليجرام أو الاتصال على 01066094050.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createAccount() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لازم توافق على الشروط والأحكام أولاً')),
      );
      return;
    }
    Navigator.pushNamed(context, '/telegram');
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'إنشاء حساب',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const QField(
            label: 'الاسم الكامل',
            hint: 'مثال: أحمد محمد',
            helper: 'اكتب الاسم كما يظهر في بطاقة الهوية أو جواز السفر',
          ),
          const QField(label: 'الإيميل', hint: 'name@example.com', keyboard: TextInputType.emailAddress),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 124,
                child: DropdownButtonFormField<String>(
                  initialValue: _dialCode,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'الدولة'),
                  items: _dialCodes
                      .map(
                        (option) => DropdownMenuItem<String>(
                              value: option.dial,
                              child: Text(option.label, overflow: TextOverflow.ellipsis),
                            ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _dialCode = value ?? '+20'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'رقم التليفون',
                    hintText: '01xxxxxxxxx',
                    helperText: 'أدخل الرقم بدون $_dialCode',
                  ),
                ),
              ),
            ],
          ),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'الباسورد',
              hintText: '••••••••',
              helperText: 'قوة كلمة المرور: $_passwordLabel',
              helperStyle: TextStyle(color: _passwordColor),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                tooltip: _obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _passwordScore / 4,
            backgroundColor: line,
            color: _passwordColor,
            minHeight: 4,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: 'GUEST',
            decoration: const InputDecoration(labelText: 'نوع الحساب'),
            items: const [
              DropdownMenuItem(value: 'GUEST', child: Text('ضيف')),
              DropdownMenuItem(value: 'OWNER', child: Text('مالك وحدة')),
              DropdownMenuItem(value: 'DRIVER', child: Text('سائق')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreed,
                  onChanged: (value) => setState(() => _agreed = value ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: _showTerms,
                  child: const Text(
                    'أوافق على الشروط والأحكام وسياسة الخصوصية',
                    style: TextStyle(color: navy, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'إنشاء الحساب', onPressed: _createAccount),
          const SizedBox(height: 12),
          const Text(
            'رقم التليفون إلزامي، وحساب واحد فقط لكل رقم.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TermSection extends StatelessWidget {
  const _TermSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: muted, height: 1.5)),
        ],
      ),
    );
  }
}

class TelegramScreen extends StatelessWidget {
  const TelegramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'تفعيل تليجرام',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PlaceholderImage(label: 'ربط الحساب بالبوت', icon: Icons.telegram_rounded, height: 140),
          const SizedBox(height: 20),
          const Text(
            'خطوة واحدة لتفعيل إشعاراتك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'افتح البوت @qiwalo_notify_bot وأرسل /start، ثم ارجع هنا. الرسالة بتوصلك علىchat_id الصحيح 6159788913.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: line)),
            child: const InfoRow('الحالة', 'في انتظار التفعيل'),
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'فتح تليجرام', onPressed: () {}),
          const SizedBox(height: 10),
          SecondaryButton(label: 'لاحقاً · اذهب للرئيسية', onPressed: () => Navigator.pushNamed(context, '/home')),
        ],
      ),
    );
  }
}

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'استعادة الباسورد',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle('١ · اطلب رابط الاستعادة'),
          const QField(label: 'الإيميل', hint: 'name@example.com', keyboard: TextInputType.emailAddress),
          PrimaryButton(label: 'إرسال الرابط', onPressed: () {}),
          const SizedBox(height: 28),
          const SectionTitle('٢ · بعد ما الرابط يوصلك'),
          const QField(label: 'رمز الاستعادة', hint: 'الرمز من الرابط'),
          const QField(label: 'باسورد جديد', hint: '••••••••', obscure: true),
          PrimaryButton(label: 'حفظ الباسورد', onPressed: () => Navigator.pushNamed(context, '/login')),
        ],
      ),
    );
  }
}
