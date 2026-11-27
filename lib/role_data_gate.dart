import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/auth_repository.dart';
import 'api/role_repository.dart';

/// يحوّل شاشات الأدوار من معاينة محلية إلى بيانات BFF فعلية.
/// مع `USE_MOCK=true` يستخدم نفس بيانات المعاينة عشان فهرس التصميم يفضل شغّال.
class RoleDataGate extends StatefulWidget {
  const RoleDataGate({
    super.key,
    required this.role,
    required this.title,
    required this.builder,
  });

  final String role;
  final String title;
  final Widget Function(BuildContext context, RoleSnapshot snapshot) builder;

  @override
  State<RoleDataGate> createState() => _RoleDataGateState();
}

class _RoleDataGateState extends State<RoleDataGate> {
  RoleSnapshot? _snapshot;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final auth = AuthRepository();
      final token = auth.useMock ? 'preview-token' : await auth.savedToken;
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'signed_out';
          _loading = false;
        });
        return;
      }
      final snapshot = await RoleRepository(useMock: auth.useMock)
          .load(role: widget.role, token: token);
      setState(() {
        _snapshot = snapshot;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final error = _error;
    if (error == 'signed_out') {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 14),
                const Text(
                  'سجّل الدخول كصاحب حساب لعرض بياناتك من الخادم.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/role-login',
                    arguments: widget.role,
                  ),
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 14),
                Text(
                  error is ApiException ? error.message : 'تعذّر تحميل البيانات. حاول مرة تانية.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.builder(context, _snapshot!);
  }
}
