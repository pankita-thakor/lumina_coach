import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/coach_prefill_provider.dart';
import '../data/situation_templates.dart';

class SituationLibraryPage extends ConsumerWidget {
  const SituationLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Situation library'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: situationTemplates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final t = situationTemplates[i];
          return Card(
            child: ListTile(
              title: Text(t.title),
              subtitle: Text(
                t.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ref.read(coachDraftPrefillProvider.notifier).state = t.body;
                context.go('/coach');
              },
            ),
          );
        },
      ),
    );
  }
}
