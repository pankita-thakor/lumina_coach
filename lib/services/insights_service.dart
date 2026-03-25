import 'functions_client.dart';

class InsightsService {
  InsightsService(this._fn);

  final FunctionsClient _fn;

  Future<String> weeklySummary({required String anthropicApiKey}) async {
    final data = await _fn.invoke(
      'insights',
      body: const <String, dynamic>{},
      anthropicApiKey: anthropicApiKey,
    );
    return data['summary'] as String? ?? '';
  }
}
