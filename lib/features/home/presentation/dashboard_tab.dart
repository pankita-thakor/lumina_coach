import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/app_theme.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
          sliver: SliverList.list(
            children: [
              _HeroCard(
                title: 'Daily challenge',
                subtitle:
                    'Practice a short negotiation opener in the simulator.',
                onPressed: () => _go(context, 2),
                cta: 'Open simulator',
              ),
              const SizedBox(height: Spacing.md),
              Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Spacing.md - 4),
              Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.auto_fix_high_rounded,
                      label: 'Coach',
                      color: scheme.primaryContainer,
                      onTap: () => _go(context, 1),
                    ),
                  ),
                  const SizedBox(width: Spacing.md - 4),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.forum_rounded,
                      label: 'Simulate',
                      color: scheme.secondaryContainer,
                      onTap: () => _go(context, 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md - 4),
              Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.library_books_outlined,
                      label: 'Situations',
                      color: scheme.tertiaryContainer,
                      onTap: () => context.push('/library'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md - 4),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.polyline_rounded,
                      label: 'Tone',
                      color: scheme.surfaceContainerHighest,
                      onTap: () => context.push('/tone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md - 4),
              Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.history_rounded,
                      label: 'History',
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      onTap: () => context.push('/history'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md - 4),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              Text('Progress', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Spacing.md - 4),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This week',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.45,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep going — drafts and simulations build momentum.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _go(BuildContext context, int branchIndex) {
    final shell = StatefulNavigationShell.of(context);
    shell.goBranch(branchIndex);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.onPressed,
    required this.cta,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppPalette.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: const Offset(0, 14),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: Spacing.md),
                FilledButton.tonal(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppPalette.primary,
                  ),
                  child: Text(cta),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: Spacing.md - 4),
              Text(label, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
