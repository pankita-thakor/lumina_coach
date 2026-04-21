import 'functions_client.dart';

class InsightsService {
  InsightsService(this._fn);

  final FunctionsClient _fn;

  Future<String> weeklySummary({required String geminiApiKey}) async {
    final data = await _fn.invoke(
      'insights',
      body: const <String, dynamic>{},
      geminiApiKey: geminiApiKey,
    );
    return data['summary'] as String? ?? '';
  }
}
