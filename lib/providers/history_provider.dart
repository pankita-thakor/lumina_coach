import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_providers.dart';

final historyMessagesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(messagesServiceProvider).list();
});
