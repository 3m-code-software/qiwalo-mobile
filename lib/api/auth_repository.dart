import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';

class MobileRoleUser {
  const MobileRoleUser({
    required this.email,
    required this.name,
    required this.role,
  });

  final String email;
  final String name;
  final String role;

  factory MobileRoleUser.fromJson(Map<String, dynamic> json) => MobileRoleUser(
        email: _text(json['email']),
        name: _text(json['name'], fallback: 'مستخدم قيوالو'),
        role: _text(json['role'], fallback: 'GUEST'),
      );
}

class MobileAuthSession {
  const MobileAuthSession({
    required this.token,
    required this.user,
    this.expiresIn = 0,
  });

  final String token;
  final MobileRoleUser user;
  final int expiresIn;

  factory MobileAuthSession.fromJson(Map<String, dynamic> json) => MobileAuthSession(
        token: _text(json['token']),
        expiresIn: json['expiresIn'] is num ? (json['expiresIn'] as num).toInt() : 0,
        user: MobileRoleUser.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        ),
      );
}

/// دخول المالك/السائق عبر BFF فقط. التوكن يُحفظ في مساحة آمنة على الجهاز،
/// وعلى الويب يكفي تخزينه في الذاكرة لجلسة المعاينة.
class AuthRepository {
  AuthRepository({ApiClient? client, bool? useMock})
      : _client = client,
        useMock = useMock ?? defaultUseMock;

  final ApiClient? _client;
  final bool useMock;

  static const bool defaultUseMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  static const String _tokenKey = 'qiwalo_mobile_token';
  static String? _memoryToken;
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient get effectiveClient => _client ?? ApiClient();

  Future<String?> get savedToken async {
    if (_memoryToken != null && _memoryToken!.isNotEmpty) return _memoryToken;
    if (kIsWeb) return null;
    try {
      final stored = await _storage.read(key: _tokenKey);
      if (stored != null && stored.isNotEmpty) {
        _memoryToken = stored;
        return stored;
      }
    } catch (_) {
      // جهاز بدون Keychain/Keystore متاح — نكمل بالجلسة في الذاكرة.
    }
    return null;
  }

  Future<void> _saveToken(String token) async {
    _memoryToken = token;
    if (kIsWeb) return;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      // التخزين الآمن مش متاح؛ التوكن يفضل في الذاكرة لهذه الجلسة.
    }
  }

  Future<void> signOut() async {
    _memoryToken = null;
    if (kIsWeb) return;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      // لا يوجد ما يُحذف.
    }
  }

  Future<MobileAuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (useMock) {
      final role = email.toLowerCase().contains('driver') ? 'DRIVER' : 'OWNER';
      final session = MobileAuthSession(
        token: 'preview-token',
        user: MobileRoleUser(email: email, name: 'مستخدم المعاينة', role: role),
      );
      await _saveToken(session.token);
      return session;
    }

    final body = await effectiveClient.postMap('/api/mobile/auth/login', body: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    if (body['ok'] != true) {
      throw ApiException(_note(body, fallback: 'تعذّر تسجيل الدخول'));
    }
    final session = MobileAuthSession.fromJson(body);
    if (session.token.isEmpty) {
      throw const ApiException('استجابة دخول غير متوقعة من الخادم');
    }
    await _saveToken(session.token);
    return session;
  }
}

String _note(Map<String, dynamic> body, {required String fallback}) {
  final note = body['note'];
  return note is String && note.isNotEmpty ? note : fallback;
}

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;
