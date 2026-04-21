import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStats {
  final int simulationCount;
  final int coachCount;

  const DashboardStats({this.simulationCount = 0, this.coachCount = 0});
}

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return const DashboardStats();

  try {
    final results = await Future.wait([
      client.from('simulator_sessions').select('id').eq('user_id', userId),
      client.from('coach_sessions').select('id').eq('user_id', userId),
    ]);

    return DashboardStats(
      simulationCount: (results[0] as List).length,
      coachCount: (results[1] as List).length,
    );
  } catch (_) {
    return const DashboardStats();
  }
});
