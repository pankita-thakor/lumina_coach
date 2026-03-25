import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/roleplay_controller.dart';

const _scenarios = [
  'Salary negotiation with manager',
  'Giving hard feedback to a peer',
  'Customer angry about billing',
  'Partner / family tense topic',
];

class SimulatorPage extends ConsumerStatefulWidget {
  const SimulatorPage({super.key});

  @override
  ConsumerState<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends ConsumerState<SimulatorPage> {
  String _scenario = _scenarios.first;
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    _input.clear();
    final err = await ref.read(roleplayControllerProvider.notifier).send(
          scenario: _scenario,
          userText: t,
        );
    if (mounted && err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
    _scrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    final rp = ref.watch(roleplayControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulator'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: () => ref.read(roleplayControllerProvider.notifier).reset(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<String>(
              value: _scenario,
              decoration: const InputDecoration(labelText: 'Scenario'),
              items: [
                for (final s in _scenarios)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: rp.busy
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() {
                          _scenario = v;
                          ref.read(roleplayControllerProvider.notifier).reset();
                        });
                      }
                    },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              itemCount: rp.lines.length,
              itemBuilder: (context, i) {
                final m = rp.lines[i];
                final mine = m.role == 'user';
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: mine
                          ? AppPalette.primary.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(Spacing.md),
                        topRight: const Radius.circular(Spacing.md),
                        bottomLeft: Radius.circular(mine ? Spacing.md : 4),
                        bottomRight: Radius.circular(mine ? 4 : Spacing.md),
                      ),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _input,
                      hint: 'Your reply…',
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  FilledButton(
                    onPressed: rp.busy ? null : _send,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(Spacing.md),
                      shape: const CircleBorder(),
                    ),
                    child: rp.busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
