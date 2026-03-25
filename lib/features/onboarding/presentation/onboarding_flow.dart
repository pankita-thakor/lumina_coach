import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/preferences_provider.dart';
import '../../../services/service_providers.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _page = PageController();
  int _index = 0;

  String? _goal;
  String? _tone;
  final Set<String> _challenges = {};

  static const _goals = [
    'Workplace clarity',
    'Negotiations',
    'Difficult conversations',
    'Personal relationships',
  ];

  static const _tones = [
    'Diplomatic',
    'Direct',
    'Warm & empathetic',
    'Concise executive',
  ];

  static const _challengeOptions = [
    'Rambling under stress',
    'Sounding too passive',
    'Sounding too blunt',
    'Avoiding hard talks',
    'Email anxiety',
  ];

  Future<void> _finish() async {
    if (AppConfig.isSupabaseConfigured) {
      try {
        await ref.read(userProfileServiceProvider).updateOnboarding(
              communicationGoal: _goal,
              toneStyle: _tone,
              challenges: _challenges.toList(),
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save profile: $e')),
          );
        }
        return;
      }
    }
    await ref.read(onboardingCompletedProvider.notifier).markCompleted();
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_index < 2) {
      _page.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_index + 1} of 3'),
        actions: [
          TextButton(
            onPressed: _index == 2 && _challenges.isNotEmpty ? _finish : null,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / 3,
            borderRadius: BorderRadius.circular(99),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _StepSelect(
                  title: 'What is your primary communication goal?',
                  subtitle:
                      'We personalize prompts and insights based on this.',
                  options: _goals,
                  selected: _goal != null ? {_goal!} : {},
                  single: true,
                  onChanged: (s) => setState(() {
                    _goal = s.singleOrNull;
                  }),
                ),
                _StepSelect(
                  title: 'Preferred tone style',
                  subtitle: 'We bias rewrites toward this voice.',
                  options: _tones,
                  selected: _tone != null ? {_tone!} : {},
                  single: true,
                  onChanged: (s) => setState(() {
                    _tone = s.singleOrNull;
                  }),
                ),
                _StepSelect(
                  title: 'Which challenges resonate?',
                  subtitle: 'Select all that apply.',
                  options: _challengeOptions,
                  selected: _challenges,
                  single: false,
                  onChanged: (s) => setState(() {
                    _challenges
                      ..clear()
                      ..addAll(s);
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_index > 0)
                  OutlinedButton(
                    onPressed: () => _page.previousPage(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                    ),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _canContinue ? _next : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                  ),
                  child: Text(_index == 2 ? 'Start coaching' : 'Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _canContinue {
    return switch (_index) {
      0 => _goal != null,
      1 => _tone != null,
      _ => _challenges.isNotEmpty,
    };
  }
}

extension<T> on Set<T> {
  T? get singleOrNull => length == 1 ? first : null;
}

class _StepSelect extends StatelessWidget {
  const _StepSelect({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.single,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final bool single;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
        const SizedBox(height: 20),
        ...options.map((o) {
          final isOn = selected.contains(o);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isOn
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (single) {
                    onChanged({o});
                  } else {
                    final next = {...selected};
                    if (next.contains(o)) {
                      next.remove(o);
                    } else {
                      next.add(o);
                    }
                    onChanged(next);
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Icon(
                        isOn
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isOn
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(o)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
