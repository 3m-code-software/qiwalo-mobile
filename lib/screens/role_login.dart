import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/auth_repository.dart';
import '../theme.dart';
import '../widgets.dart';

class RoleLoginScreen extends StatefulWidget {
  const RoleLoginScreen({super.key, this.role = 'OWNER'});

  final String role;

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  late String _role = widget.role;
  late final TextEditingController _email = TextEditingController(
    text: AuthRepository.defaultUseMock
        ? (_role == 'DRIVER' ? 'driver@qiwalo.test' : 'owner@qiwalo.test')
        : '',
  );
  final TextEditingController _password = TextEditingController(
    text: AuthRepository.defaultUseMock ? 'Qiwalo123' : '',
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await AuthRepository().signIn(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      final target = session.user.role == 'DRIVER'
          ? '/driver-dashboard'
          : '/owner-dashboard';
      Navigator.pushReplacementNamed(context, target);
    } on ApiException catch (error) {
      setState(() {
        _busy = false;
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _busy = false;
        _error = 'تعذّر تسجيل الدخول. حاول مرة تانية.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'دخول المالك والسائق',
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
                Text('حسابك على قيوالو', style: TextStyle(color: gold, fontSize: 13)),
                SizedBox(height: 6),
                Text(
                  'البيانات بتاعة حسابك بس، من الخادم مباشرة',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'OWNER', label: Text('مالك'), icon: Icon(Icons.apartment_rounded)),
              ButtonSegment(value: 'DRIVER', label: Text('سائق'), icon: Icon(Icons.directions_car_rounded)),
            ],
            selected: <String>{_role},
            onSelectionChanged: (value) => setState(() {
              _role = value.first;
              if (AuthRepository.defaultUseMock) {
                _email.text = _role == 'DRIVER' ? 'driver@qiwalo.test' : 'owner@qiwalo.test';
              }
            }),
          ),
          const SizedBox(height: 16),
          QField(label: 'البريد الإلكتروني', hint: 'name@example.com', controller: _email),
          const SizedBox(height: 10),
          QField(
            label: 'كلمة المرور',
            hint: '••••••••',
            controller: _password,
            obscure: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 18),
          PrimaryButton(
            label: _busy ? 'جارٍ الدخول...' : 'دخول',
            onPressed: _busy ? null : _submit,
          ),
          const SizedBox(height: 12),
          Text(
            'ضيوف قيوالو يكملوا الحجز من غير دخول، زي ما كانوا بيعملوا قبل كدة.',
            style: TextStyle(color: muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
