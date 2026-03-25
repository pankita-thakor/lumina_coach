import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_api_key_storage.dart';
import '../services/service_providers.dart';

class RoleLine {
  const RoleLine({required this.role, required this.text});
  final String role;
  final String text;
}

class RoleplayUiState {
  const RoleplayUiState({
    this.lines = const [],
    this.sessionId,
    this.busy = false,
  });

  final List<RoleLine> lines;
  final String? sessionId;
  final bool busy;
}

class RoleplayController extends StateNotifier<RoleplayUiState> {
  RoleplayController(this._ref) : super(const RoleplayUiState());

  final Ref _ref;

  Future<String?> send({
    required String scenario,
    required String userText,
  }) async {
    final key = await SecureApiKeyStorage.readAnthropicKey();
    if (key == null || key.isEmpty) {
      return 'Add Anthropic API key in Settings';
    }

    final sid = state.sessionId;
    final userLine = RoleLine(role: 'user', text: userText);
    state = RoleplayUiState(
      lines: [...state.lines, userLine],
      sessionId: sid,
      busy: true,
    );

    try {
      final res = await _ref.read(roleplayServiceProvider).send(
            sessionId: sid,
            scenario: scenario,
            userMessage: userText,
            anthropicApiKey: key,
          );
      state = RoleplayUiState(
        lines: [
          ...state.lines,
          RoleLine(role: 'assistant', text: res.reply),
        ],
        sessionId: res.sessionId,
        busy: false,
      );
      return null;
    } catch (e) {
      state = RoleplayUiState(
        lines: [
          ...state.lines,
          RoleLine(role: 'assistant', text: 'Error: $e'),
        ],
        sessionId: state.sessionId,
        busy: false,
      );
      return e.toString();
    }
  }

  void reset() => state = const RoleplayUiState();
}

final roleplayControllerProvider =
    StateNotifierProvider<RoleplayController, RoleplayUiState>(
  RoleplayController.new,
);
