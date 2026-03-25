import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/tone_analysis_controller.dart';

class ToneAnalyzerPage extends ConsumerStatefulWidget {
  const ToneAnalyzerPage({super.key});

  @override
  ConsumerState<ToneAnalyzerPage> createState() => _ToneAnalyzerPageState();
}

class _ToneAnalyzerPageState extends ConsumerState<ToneAnalyzerPage> {
  final _text = TextEditingController();

  static const _keys = ['empathy', 'clarity', 'assertiveness', 'warmth'];
  static const _labels = ['Empathy', 'Clarity', 'Assertiveness', 'Warmth'];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    await ref.read(toneAnalysisControllerProvider.notifier).analyze(body);
  }

  @override
  Widget build(BuildContext context) {
    final tone = ref.watch(toneAnalysisControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tone analyzer')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Text(
            'Analyze perceived empathy, clarity, assertiveness, and warmth '
            '(0–100 heuristic, not psychological testing).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: Spacing.md),
          AppTextField(
            controller: _text,
            hint: 'Paste message to analyze',
            minLines: 4,
            maxLines: 10,
          ),
          if (tone.hasError) ...[
            const SizedBox(height: Spacing.md),
            Text(
              tone.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: Spacing.md),
          AppPrimaryButton(
            label: tone.isLoading ? 'Analyzing…' : 'Analyze',
            icon: Icons.polyline_rounded,
            busy: tone.isLoading,
            onPressed: tone.isLoading ? null : _analyze,
          ),
          ...switch (tone) {
            AsyncData(:final value) when value != null => [
                const SizedBox(height: Spacing.xl),
                SizedBox(
                  height: 280,
                  child: RadarChart(
                    RadarChartData(
                      radarBorderData:
                          const BorderSide(color: Colors.transparent),
                      gridBorderData: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      tickBorderData: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                      radarShape: RadarShape.polygon,
                      tickCount: 4,
                      ticksTextStyle: Theme.of(context).textTheme.labelSmall,
                      titleTextStyle: Theme.of(context).textTheme.labelSmall,
                      getTitle: (index, angle) => RadarChartTitle(
                        text: _labels[index],
                        angle: angle,
                      ),
                      dataSets: [
                        RadarDataSet(
                          fillColor: AppPalette.primary.withValues(alpha: 0.25),
                          borderColor: AppPalette.primary,
                          borderWidth: 2,
                          entryRadius: 2,
                          dataEntries: [
                            RadarEntry(
                                value: value.empathy.toDouble()),
                            RadarEntry(
                                value: value.clarity.toDouble()),
                            RadarEntry(
                                value: value.assertiveness.toDouble()),
                            RadarEntry(
                                value: value.warmth.toDouble()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.md,
                  runSpacing: Spacing.sm,
                  children: [
                    _chip('Empathy', value.empathy),
                    _chip('Clarity', value.clarity),
                    _chip('Assertive', value.assertiveness),
                    _chip('Warmth', value.warmth),
                  ],
                ),
              ],
            _ => [],
          },
        ],
      ),
    );
  }

  Widget _chip(String label, int v) {
    return Chip(label: Text('$label: $v%'));
  }
}
