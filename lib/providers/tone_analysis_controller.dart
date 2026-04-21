import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_providers.dart';
import '../services/tone_analysis_service.dart';
import 'gemini_key_provider.dart';

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
      final key = ref.read(geminiKeyProvider);
      if (key == null || key.isEmpty) {
        throw Exception('Add your Gemini API key in Settings.');
      }
      return ref.read(toneAnalysisServiceProvider).analyze(
            message: message,
            geminiApiKey: key,
          );
    });
  }

  void clear() => state = const AsyncData(null);
}
