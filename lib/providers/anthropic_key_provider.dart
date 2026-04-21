import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_provider.dart';

const _kAnthropicKey = 'anthropic_api_key';

class AnthropicKeyNotifier extends StateNotifier<String?> {
  AnthropicKeyNotifier(this._prefs, String? initialKey) : super(initialKey);

  final SharedPreferences _prefs;

  Future<void> save(String key) async {
    final trimmed = key.trim();
    await _prefs.setString(_kAnthropicKey, trimmed);
    state = trimmed.isNotEmpty ? trimmed : null;
  }

  Future<void> clear() async {
    await _prefs.remove(_kAnthropicKey);
    state = null;
  }
}

final anthropicKeyProvider =
    StateNotifierProvider<AnthropicKeyNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final stored = prefs.getString(_kAnthropicKey);
  final initial = (stored != null && stored.isNotEmpty) ? stored : null;
  return AnthropicKeyNotifier(prefs, initial);
});
