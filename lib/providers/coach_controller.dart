import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/coach_service.dart';
import '../services/service_providers.dart';
import 'gemini_key_provider.dart';

final coachRewriteProvider =
    AsyncNotifierProvider<CoachRewriteNotifier, List<Map<String, dynamic>>?>(
  CoachRewriteNotifier.new,
);

class CoachRewriteNotifier extends AsyncNotifier<List<Map<String, dynamic>>?> {
  @override
  FutureOr<List<Map<String, dynamic>>?> build() => null;

  CoachService get _svc => ref.read(coachServiceProvider);

  Future<void> runRewrite(String message, String context) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final key = ref.read(geminiKeyProvider);
      if (key == null || key.isEmpty) {
        throw Exception('Add your Gemini API key in Settings.');
      }
      return _svc.rewrite(
        message: message,
        context: context,
        geminiApiKey: key,
      );
    });
  }

  void clear() => state = const AsyncData(null);
}
