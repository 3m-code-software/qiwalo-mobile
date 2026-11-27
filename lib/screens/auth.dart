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
                  _feature(Icons.search_rounded, 'ابحث', 'وحدات بأسعار واضحة وتوافر محدّث'),
                  _feature(Icons.terrain_rounded, 'خطّط', 'سفاري ونقل وباقات في مكان واحد'),
                  _feature(Icons.support_agent_rounded, 'تواصل', 'دعم عربي على مدار اليوم'),
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

  Widget _feature(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
        ],
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'تسجيل الدخول',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PlaceholderImage(label: 'قيوالو', icon: Icons.login_rounded, height: 110),
          const SizedBox(height: 20),
          const QField(label: 'الإيميل', hint: 'name@example.com', keyboard: TextInputType.emailAddress),
          const QField(label: 'الباسورد', hint: '••••••••', obscure: true),
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

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'إنشاء حساب',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const QField(label: 'الاسم الكامل', hint: 'مثال: أحمد محمد'),
          const QField(label: 'الإيميل', hint: 'name@example.com', keyboard: TextInputType.emailAddress),
          const QField(label: 'رقم التليفون', hint: '01xxxxxxxxx', keyboard: TextInputType.phone),
          const QField(label: 'الباسورد', hint: '••••••••', obscure: true),
          const SizedBox(height: 4),
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
            children: const [
              SizedBox(width: 24, height: 24, child: Checkbox(value: true, onChanged: null)),
              SizedBox(width: 8),
              Expanded(child: Text('أوافق على الشروط والأحكام وسياسة الخصوصية')),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'إنشاء الحساب', onPressed: () => Navigator.pushNamed(context, '/telegram')),
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
