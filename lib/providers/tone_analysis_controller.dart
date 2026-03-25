import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_api_key_storage.dart';
import '../services/service_providers.dart';
import '../services/tone_analysis_service.dart';

final toneAnalysisControllerProvider =
    AsyncNotifierProvider<ToneAnalysisNotifier, ToneScores?>(
  ToneAnalysisNotifier.new,
);

class ToneAnalysisNotifier extends AsyncNotifier<ToneScores?> {
  @override
  FutureOr<ToneScores?> build() => null;

  Future<void> analyze(String message) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final key = await SecureApiKeyStorage.readAnthropicKey();
      if (key == null || key.isEmpty) {
        throw Exception('Add Anthropic API key in Settings');
      }
      return ref.read(toneAnalysisServiceProvider).analyze(
            message: message,
            anthropicApiKey: key,
          );
    });
  }

  void clear() => state = const AsyncData(null);
}
