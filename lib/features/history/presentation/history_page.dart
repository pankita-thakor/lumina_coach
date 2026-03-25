import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(historyMessagesProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: Spacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(historyMessagesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No saved drafts yet.'));
          }
          final fmt = DateFormat.MMMd().add_jm();
          return ListView.separated(
            padding: const EdgeInsets.all(Spacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
            itemBuilder: (context, i) {
              final m = items[i];
              final t = DateTime.tryParse(m['created_at'] as String? ?? '');
              return Card(
                child: ListTile(
                  title: Text(
                    (m['content'] as String?) ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${m['context'] ?? ''}${t != null ? ' · ${fmt.format(t.toLocal())}' : ''}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
