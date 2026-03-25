import 'functions_client.dart';

class CoachService {
  CoachService(this._fn);

  final FunctionsClient _fn;

  Future<List<Map<String, dynamic>>> rewrite({
    required String message,
    required String context,
    required String anthropicApiKey,
  }) async {
    final data = await _fn.invoke(
      'rewrite-message',
      body: {'message': message, 'context': context},
      anthropicApiKey: anthropicApiKey,
    );
    final list = data['suggestions'] as List? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
