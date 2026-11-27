import 'dart:convert';

import 'package:http/http.dart' as http;

/// العنوان يحدد وقت البناء:
/// flutter build apk --dart-define=API_BASE_URL=http://192.168.1.5:3130
const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://qiwalo-ygzh.vercel.app',
);

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'ApiException: $message'
      : 'ApiException($statusCode): $message';
}

/// عميل HTTP بسيط يتكلم مع Next.js BFF. يستخدم حزمة http عشان يشتغل على أندرويد ويب.
class ApiClient {
  ApiClient({String? baseUrl, http.Client? httpClient})
      : baseUrl = baseUrl ?? defaultApiBaseUrl,
        _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  Uri _uri(String path, [Map<String, String>? query]) {
    final clean = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$clean').replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? query,
    String? token,
  }) async {
    final response = await _get(path, query: query, token: token);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('استجابة غير متوقعة من الخادم');
    }
    return decoded;
  }

  /// POST JSON للـ BFF. رسائل الخطأ العربية القادمة من الخادم تظهر كما هي.
  Future<Map<String, dynamic>> postMap(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };
    late final http.Response response;
    try {
      response = await _http.post(
        _uri(path),
        headers: requestHeaders,
        body: jsonEncode(body),
      );
    } catch (error) {
      throw ApiException('تعذّر الاتصال بالخادم: $error');
    }

    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(response.body);
      if (value is Map<String, dynamic>) decoded = value;
    } catch (_) {
      decoded = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final note = decoded?['note'];
      throw ApiException(
        note is String && note.isNotEmpty
            ? note
            : 'فشل الطلب (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (decoded == null) {
      throw const ApiException('استجابة غير متوقعة من الخادم');
    }
    return decoded;
  }

  /// PATCH JSON للـ BFF. نفس معالجة أخطاء POST، مع إمكانية تمرير توكن الأدوار.
  Future<Map<String, dynamic>> patchMap(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };
    late final http.Response response;
    try {
      response = await _http.patch(
        _uri(path),
        headers: requestHeaders,
        body: jsonEncode(body),
      );
    } catch (error) {
      throw ApiException('تعذّر الاتصال بالخادم: $error');
    }

    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(response.body);
      if (value is Map<String, dynamic>) decoded = value;
    } catch (_) {
      decoded = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final note = decoded?['note'];
      throw ApiException(
        note is String && note.isNotEmpty
            ? note
            : 'فشل الطلب (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (decoded == null) {
      throw const ApiException('استجابة غير متوقعة من الخادم');
    }
    return decoded;
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
    String? token,
  }) async {
    final response = await _get(path, query: query, token: token);
    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const ApiException('استجابة غير متوقعة من الخادم');
    }
    return decoded;
  }

  Future<http.Response> _get(
    String path, {
    Map<String, String>? query,
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    late final http.Response response;
    try {
      response = await _http.get(_uri(path, query), headers: headers);
    } catch (error) {
      throw ApiException('تعذّر الاتصال بالخادم: $error');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'فشل الطلب (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  void dispose() => _http.close();
}
