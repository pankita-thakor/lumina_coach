import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Situation library sets draft text before navigating to Coach.
final coachDraftPrefillProvider = StateProvider<String?>((ref) => null);
