import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_provider.dart';

const _kGeminiKey = 'gemini_api_key';

class GeminiKeyNotifier extends StateNotifier<String?> {
  GeminiKeyNotifier(this._prefs, String? initialKey) : super(initialKey);

  final SharedPreferences _prefs;

  Future<void> save(String key) async {
    final trimmed = key.trim();
    await _prefs.setString(_kGeminiKey, trimmed);
    state = trimmed.isNotEmpty ? trimmed : null;
  }

  Future<void> clear() async {
    await _prefs.remove(_kGeminiKey);
    state = null;
  }
}

final geminiKeyProvider =
    StateNotifierProvider<GeminiKeyNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final stored = prefs.getString(_kGeminiKey);
  final initial = (stored != null && stored.isNotEmpty) ? stored : null;
  return GeminiKeyNotifier(prefs, initial);
});
