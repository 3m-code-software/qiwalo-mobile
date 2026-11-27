import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../widgets.dart';

const String supportPhone = '01066094050';
const String supportWhatsapp = 'https://wa.me/201066094050';
const String supportTelegram = 'https://t.me/+201066094050';

/// صفحة تواصل داخلية داخل التطبيق: قنوات جاهزة + رسالة تتبعتح واتساب أو تليجرام.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _urlWithMessage(String base) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return base;
    final separator = base.contains('?') ? '&' : '?';
    return '$base${separator}text=${Uri.encodeQueryComponent(text)}';
  }

  Future<void> _open(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        _snack('ماقدرناش نفتح قناة التواصل على الجهاز ده');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _snack('حصل خطأ أثناء فتح قناة التواصل');
    }
  }

  Future<void> _send(String base) async {
    if (_messageController.text.trim().isEmpty) {
      _snack('اكتب رسالتك أولاً');
      return;
    }
    await _open(_urlWithMessage(base));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'تواصل معنا',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: gold, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فريق قيوالو جاهز للمساعدة',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'دعم عربي على مدار اليوم · الأقصر وأسوان',
                        style: TextStyle(color: Color(0xFFC7D2DF), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('قنوات التواصل'),
          _channel(
            icon: Icons.chat_rounded,
            color: const Color(0xFF25D366),
            title: 'واتساب',
            subtitle: supportWhatsapp,
            onTap: () => _open(_urlWithMessage(supportWhatsapp)),
          ),
          _channel(
            icon: Icons.telegram_rounded,
            color: const Color(0xFF229ED9),
            title: 'تليجرام',
            subtitle: supportTelegram,
            onTap: () => _open(_urlWithMessage(supportTelegram)),
          ),
          _channel(
            icon: Icons.call_rounded,
            color: navy,
            title: 'تليفون',
            subtitle: supportPhone,
            onTap: () => _open('tel:$supportPhone'),
          ),
          const SectionTitle('اكتب رسالتك'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'رسالتك',
                  hintText: 'اكتب استفسارك أو رقم مرجع الحجز...',
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
            onPressed: () => _send(supportWhatsapp),
            icon: const Icon(Icons.chat_rounded),
            label: const Text('إرسال عبر واتساب'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _send(supportTelegram),
            icon: const Icon(Icons.telegram_rounded),
            label: const Text('إرسال عبر تليجرام'),
          ),
          const SizedBox(height: 20),
          const Text(
            'لو عندك حجز، اذكر رقم المرجع عشان نسرّع الرد.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _channel({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
