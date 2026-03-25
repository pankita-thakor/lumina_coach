import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/coach_controller.dart';
import '../../../providers/coach_prefill_provider.dart';

const _contexts = [
  'Work',
  'Relationship',
  'Negotiation',
  'Crisis',
];

class CoachPage extends ConsumerStatefulWidget {
  const CoachPage({super.key});

  @override
  ConsumerState<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends ConsumerState<CoachPage> {
  final _text = TextEditingController();
  String _ctx = _contexts.first;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pre = ref.read(coachDraftPrefillProvider);
      if (pre != null && pre.isNotEmpty) {
        _text.text = pre;
        ref.read(coachDraftPrefillProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    await ref.read(coachRewriteProvider.notifier).runRewrite(body, _ctx);
  }

  void _onChangedDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final rewrite = ref.watch(coachRewriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        actions: [
          IconButton(
            tooltip: 'Clear result',
            onPressed: () =>
                ref.read(coachRewriteProvider.notifier).clear(),
            icon: const Icon(Icons.clear_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Text(
            'Paste a message. We will suggest calibrations with tone labels.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: Spacing.md),
          AppTextField(
            controller: _text,
            hint: 'What do you want to say?',
            minLines: 5,
            maxLines: 12,
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Context',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: _contexts
                .map(
                  (c) => ChoiceChip(
                    label: Text(c),
                    selected: _ctx == c,
                    onSelected: (_) => setState(() => _ctx = c),
                  ),
                )
                .toList(),
          ),
          if (rewrite.hasError) ...[
            const SizedBox(height: Spacing.md),
            Text(
              rewrite.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          AppPrimaryButton(
            label: rewrite.isLoading ? 'Generating…' : 'Generate suggestions',
            icon: Icons.bolt_rounded,
            busy: rewrite.isLoading,
            onPressed: rewrite.isLoading || _text.text.trim().isEmpty
                ? null
                : _run,
          ),
          const SizedBox(height: Spacing.xl),
          ...switch (rewrite) {
            AsyncData(:final value) when value != null && value.isNotEmpty =>
              [
                Text(
                  'Suggestions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.md),
                ...value.map(_SuggestionCard.new),
              ],
            _ => [],
          },
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard(this.item);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final tone = item['tone'] as String? ?? 'Suggestion';
    final text = item['text'] as String? ?? '';
    final why = item['why'] as String?;
    final extra = (why != null && why.isNotEmpty) ? '\n\n$why' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Text(tone, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            SelectableText(text + extra),
          ],
        ),
      ),
    );
  }
}
