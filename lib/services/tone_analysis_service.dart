import 'functions_client.dart';

class ToneScores {
  ToneScores({
    required this.empathy,
    required this.clarity,
    required this.assertiveness,
    required this.warmth,
  });

  final int empathy;
  final int clarity;
  final int assertiveness;
  final int warmth;
}

class ToneAnalysisService {
  ToneAnalysisService(this._fn);

  final FunctionsClient _fn;

  Future<ToneScores> analyze({
    required String message,
    required String anthropicApiKey,
  }) async {
    final data = await _fn.invoke(
      'analyze-tone',
      body: {'message': message},
      anthropicApiKey: anthropicApiKey,
    );
    final s = Map<String, dynamic>.from(data['scores'] as Map? ?? {});
    int v(String k) => (s[k] as num?)?.round().clamp(0, 100) ?? 0;
    return ToneScores(
      empathy: v('empathy'),
      clarity: v('clarity'),
      assertiveness: v('assertiveness'),
      warmth: v('warmth'),
    );
  }
}
