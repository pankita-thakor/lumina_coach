import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coach_service.dart';
import 'functions_client.dart';
import 'insights_service.dart';
import 'messages_service.dart';
import 'roleplay_service.dart';
import 'tone_analysis_service.dart';
import 'user_profile_service.dart';

final coachServiceProvider = Provider<CoachService>(
  (ref) => CoachService(ref.watch(functionsClientProvider)),
);

final toneAnalysisServiceProvider = Provider<ToneAnalysisService>(
  (ref) => ToneAnalysisService(ref.watch(functionsClientProvider)),
);

final roleplayServiceProvider = Provider<RoleplayService>(
  (ref) => RoleplayService(ref.watch(functionsClientProvider)),
);

final insightsServiceProvider = Provider<InsightsService>(
  (ref) => InsightsService(ref.watch(functionsClientProvider)),
);

final messagesServiceProvider = Provider<MessagesService>(
  (ref) => MessagesService(ref.watch(functionsClientProvider)),
);

final userProfileServiceProvider = Provider<UserProfileService>(
  (ref) => UserProfileService(ref.watch(functionsClientProvider)),
);
