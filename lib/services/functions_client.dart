import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';

class FunctionsException implements Exception {
  FunctionsException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Invokes Supabase Edge Functions; parses `{ success, data, error }` (BACKEND.md §6).
class FunctionsClient {
  FunctionsClient(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> invoke(
    String functionName, {
    Map<String, dynamic> body = const {},
    String geminiApiKey = '',
  }) async {
    final headers = <String, String>{};
    if (geminiApiKey.isNotEmpty) {
      headers['x-gemini-key'] = geminiApiKey;
    }

    final res = await _client.functions.invoke(
      functionName,
      body: body,
      headers: headers,
    );

    dynamic raw = res.data;
    if (kDebugMode) {
      debugPrint('functions.$functionName raw=${raw.runtimeType}');
    }

    Map<String, dynamic> envelope;
    if (raw is String) {
      envelope = jsonDecode(raw) as Map<String, dynamic>;
    } else if (raw is Map) {
      envelope = Map<String, dynamic>.from(raw);
    } else {
      throw FunctionsException('Unexpected response');
    }

    if (envelope['success'] != true) {
      throw FunctionsException(
        envelope['error']?.toString() ?? 'Request failed',
      );
    }

    final data = envelope['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data == null) return {};
    throw FunctionsException('Invalid data payload');
  }
}

final functionsClientProvider = Provider<FunctionsClient>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    throw StateError('Supabase not configured');
  }
  return FunctionsClient(Supabase.instance.client);
});
