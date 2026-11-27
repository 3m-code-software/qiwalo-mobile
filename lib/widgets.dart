import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final int? navIndex;
  final Widget? bottomBar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.navIndex,
    this.bottomBar,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'رجوع',
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: 'كل الشاشات',
            onPressed: () => Navigator.pushNamed(context, '/design'),
          ),
          ...?actions,
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomBar ??
          (navIndex == null ? null : QBottomNav(current: navIndex!)),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;
}

const List<_NavItem> _navItems = [
  _NavItem(Icons.home_rounded, 'الرئيسية', '/home'),
  _NavItem(Icons.favorite_border_rounded, 'المفضلة', '/favorites'),
  _NavItem(Icons.receipt_long_rounded, 'حجوزاتي', '/bookings'),
  _NavItem(Icons.person_outline_rounded, 'حسابي', '/profile'),
];

class QBottomNav extends StatelessWidget {
  final int current;
  const QBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: navy,
      unselectedItemColor: muted,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: _navItems
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
      onTap: (index) =>
          Navigator.pushReplacementNamed(context, _navItems[index].route),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(label));
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: Text(label));
}

class QField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  final String? helper;
  const QField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboard,
    this.controller,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, hintText: hint, helperText: helper),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: ink,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderImage extends StatelessWidget {
  final String label;
  final IconData icon;
  final double height;
  final Color color;
  const PlaceholderImage({
    super.key,
    required this.label,
    required this.icon,
    this.height = 180,
    this.color = navy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, navyLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: gold),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// صورة من BFF مع بديل محلي لو الإنترنت أو الرابط مش متاح.
class UnitImage extends StatelessWidget {
  const UnitImage({super.key, required this.url, this.height, this.fit = BoxFit.cover});

  final String url;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height ?? 180,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (_, _, _) => PlaceholderImage(
        label: 'صورة الوحدة',
        icon: Icons.apartment_rounded,
        height: height ?? 180,
      ),
    );
  }
}

class StayCard extends StatelessWidget {
  final Stay stay;
  const StayCard({super.key, required this.stay});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/unit', arguments: stay.slug),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: PlaceholderImage(
                label: 'صورة الوحدة',
                icon: stay.icon,
                color: stay.color,
                height: 120,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stay.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('${stay.city} · ${stay.type}', style: const TextStyle(color: muted)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stay.price, style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: gold),
                          Text(stay.rating),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceBox extends StatelessWidget {
  final List<PriceLine> lines;
  final String total;
  const PriceBox({super.key, required this.lines, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          ...lines.map((line) => InfoRow(line.label, line.value)),
          const Divider(),
          InfoRow('الإجمالي', total),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
