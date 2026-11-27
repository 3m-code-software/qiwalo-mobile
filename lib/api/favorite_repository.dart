import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// المفضلة بتاعة الجهاز: بنخزّن slugs الوحدات فقط، من غير بيانات شخصية.
/// على الويب بنكتفي بالذاكرة عشان فهرس المراجعة يشتغل من غير تخزين دائم.
class FavoriteRepository {
  const FavoriteRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String storageKey = 'qiwalo_favorite_slugs';
  static List<String> _memory = <String>[];

  final FlutterSecureStorage _storage;

  Future<List<String>> load() async {
    if (!kIsWeb) {
      try {
        final raw = await _storage.read(key: storageKey);
        if (raw != null) _memory = _decode(raw);
      } catch (_) {
        // جهاز بدون تخزين آمن — نكمل بالقائمة في الذاكرة لهذه الجلسة.
      }
    }
    return List<String>.unmodifiable(_memory);
  }

  Future<bool> toggle(String slug) async {
    final clean = slug.trim();
    if (clean.isEmpty) return false;
    final current = await load();
    final next = <String>[];
    for (final item in current) {
      if (item != clean) next.add(item);
    }
    final added = next.length == current.length;
    if (added) next.add(clean);
    _memory = next;
    await _persist();
    return added;
  }

  Future<void> remove(String slug) async {
    final current = await load();
    _memory = current.where((item) => item != slug).toList();
    await _persist();
  }

  Future<void> _persist() async {
    if (kIsWeb) return;
    try {
      await _storage.write(key: storageKey, value: jsonEncode(_memory));
    } catch (_) {
      // التخزين مش متاح؛ المفضلة تفضل في الذاكرة.
    }
  }

  static List<String> _decode(String raw) {
    try {
      final value = jsonDecode(raw);
      if (value is List) {
        return value.whereType<String>().toList();
      }
    } catch (_) {
      // قيمة قديمة أو تالفة — نبدأ من قائمة فاضية.
    }
    return <String>[];
  }
}
