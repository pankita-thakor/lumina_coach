import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_providers.dart';
import 'gemini_key_provider.dart';

final insightsControllerProvider = AsyncNotifierProvider<InsightsNotifier, String?>(
  InsightsNotifier.new,
);

class InsightsNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<void> generate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final key = ref.read(geminiKeyProvider);
      if (key == null || key.isEmpty) {
        throw Exception('Add your Gemini API key in Settings.');
      }
      return ref.read(insightsServiceProvider).weeklySummary(
            geminiApiKey: key,
          );
    });
  }

  void clear() => state = const AsyncData(null);
}
