import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/insights_controller.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ins = ref.watch(insightsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: () =>
                ref.read(insightsControllerProvider.notifier).clear(),
            icon: const Icon(Icons.clear_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Text(
            'Weekly coaching summary from your recent activity. '
            'Run after you have used Coach or Simulator for richer output.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
          ),
          const SizedBox(height: Spacing.md),
          AppPrimaryButton(
            label: ins.isLoading ? 'Analyzing…' : 'Generate this week',
            icon: Icons.insights_outlined,
            busy: ins.isLoading,
            onPressed:
                ins.isLoading ? null : () => ref.read(insightsControllerProvider.notifier).generate(),
          ),
          if (ins.hasError) ...[
            const SizedBox(height: Spacing.md),
            Text(
              ins.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (ins.hasValue &&
              ins.value != null &&
              ins.value!.isNotEmpty) ...[
            const SizedBox(height: Spacing.xl),
            SelectableText(
              ins.value!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}
