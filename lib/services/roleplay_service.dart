import 'functions_client.dart';

class RoleplayResult {
  RoleplayResult({required this.reply, required this.sessionId});

  final String reply;
  final String sessionId;
}

class RoleplayService {
  RoleplayService(this._fn);

  final FunctionsClient _fn;

  Future<RoleplayResult> send({
    String? sessionId,
    required String scenario,
    required String userMessage,
    required String anthropicApiKey,
  }) async {
    final body = <String, dynamic>{
      'scenario': scenario,
      'userMessage': userMessage,
    };
    if (sessionId != null) body['sessionId'] = sessionId;

    final data = await _fn.invoke(
      'roleplay',
      body: body,
      anthropicApiKey: anthropicApiKey,
    );

    return RoleplayResult(
      reply: data['reply'] as String? ?? '',
      sessionId: data['sessionId'] as String? ?? sessionId ?? '',
    );
  }
}
