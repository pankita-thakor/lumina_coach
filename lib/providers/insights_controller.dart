import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_api_key_storage.dart';
import '../services/service_providers.dart';

final insightsControllerProvider = AsyncNotifierProvider<InsightsNotifier, String?>(
  InsightsNotifier.new,
);

class InsightsNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<void> generate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final key = await SecureApiKeyStorage.readAnthropicKey();
      if (key == null || key.isEmpty) {
        throw Exception('Add Anthropic API key in Settings');
      }
      return ref.read(insightsServiceProvider).weeklySummary(
            anthropicApiKey: key,
          );
    });
  }

  void clear() => state = const AsyncData(null);
}
