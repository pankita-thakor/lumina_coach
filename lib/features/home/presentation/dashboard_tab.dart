import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import 'dashboard_provider.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.email?.split('@').first ?? 'there';
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Lumina Coach',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: Spacing.lg, bottom: Spacing.md),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primaryContainer.withValues(alpha: 0.3),
                      scheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(width: Spacing.sm),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.lg),
            sliver: SliverList.list(
              children: [
                Text(
                  'Hi, $displayName!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Welcome back to Lumina Coach',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                _HeroActionCard(
                  title: 'Ready for your daily session?',
                  subtitle: 'Master the art of negotiation in 5 minutes.',
                  icon: Icons.auto_awesome_rounded,
                  cta: 'Start Simulator',
                  onPressed: () => _go(context, 2),
                ),
                const SizedBox(height: Spacing.xl),
                
                _SectionHeader(
                  title: 'Quick Actions',
                  onSeeAll: () {},
                ),
                const SizedBox(height: Spacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: Spacing.md,
                  crossAxisSpacing: Spacing.md,
                  childAspectRatio: 1.1,
                  children: [
                    _QuickActionTile(
                      label: 'AI Coach',
                      icon: Icons.psychology_rounded,
                      color: scheme.primary,
                      onTap: () => _go(context, 1),
                    ),
                    _QuickActionTile(
                      label: 'Simulator',
                      icon: Icons.forum_rounded,
                      color: scheme.secondary,
                      onTap: () => _go(context, 2),
                    ),
                    _QuickActionTile(
                      label: 'Library',
                      icon: Icons.local_library_rounded,
                      color: scheme.tertiary,
                      onTap: () => context.push('/library'),
                    ),
                    _QuickActionTile(
                      label: 'Tone Analysis',
                      icon: Icons.analytics_rounded,
                      color: AppPalette.accentRose,
                      onTap: () => context.push('/tone'),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),
                
                _SectionHeader(
                  title: 'Recent Progress',
                  onSeeAll: () => context.push('/history'),
                ),
                const SizedBox(height: Spacing.md),
                statsAsync.when(
                  loading: () => AppCard(
                    child: Column(
                      children: [
                        _ProgressRow(label: 'Simulations', value: 0, color: scheme.primary, count: '…'),
                        const Divider(height: Spacing.xl),
                        _ProgressRow(label: 'Coach Insights', value: 0, color: scheme.secondary, count: '…'),
                      ],
                    ),
                  ),
                  error: (_, __) => AppCard(
                    child: Column(
                      children: [
                        _ProgressRow(label: 'Simulations', value: 0, color: scheme.primary, count: '0/15'),
                        const Divider(height: Spacing.xl),
                        _ProgressRow(label: 'Coach Insights', value: 0, color: scheme.secondary, count: '0/10'),
                      ],
                    ),
                  ),
                  data: (stats) => AppCard(
                    child: Column(
                      children: [
                        _ProgressRow(
                          label: 'Simulations',
                          value: (stats.simulationCount / 15).clamp(0.0, 1.0),
                          color: scheme.primary,
                          count: '${stats.simulationCount}/15',
                        ),
                        const Divider(height: Spacing.xl),
                        _ProgressRow(
                          label: 'Coach Insights',
                          value: (stats.coachCount / 10).clamp(0.0, 1.0),
                          color: scheme.secondary,
                          count: '${stats.coachCount}/10',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                
                _SectionHeader(title: 'Daily Tip'),
                const SizedBox(height: Spacing.md),
                AppCard(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lightbulb_outline_rounded, color: scheme.primary),
                      ),
                      const SizedBox(width: Spacing.md),
                      const Expanded(
                        child: Text(
                          'Mirroring your partner\'s last three words helps build rapport quickly.',
                          style: TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, int branchIndex) {
    final shell = StatefulNavigationShell.of(context);
    shell.goBranch(branchIndex);
  }
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cta,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String cta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppPalette.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppPalette.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      cta,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See all'),
          ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: isDark ? 0.15 : 0.08),
              color.withValues(alpha: isDark ? 0.05 : 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Spacing.md + 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
    required this.count,
  });

  final String label;
  final double value;
  final Color color;
  final String count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              count,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
