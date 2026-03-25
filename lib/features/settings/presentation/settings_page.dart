import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/storage/secure_api_key_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/preferences_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _keyCtrl = TextEditingController();
  bool _mask = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final k = await SecureApiKeyStorage.readAnthropicKey();
    if (k != null && mounted) {
      _keyCtrl.text = k;
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    setState(() => _saving = true);
    try {
      await SecureApiKeyStorage.saveAnthropicKey(_keyCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key saved on this device')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearKey() async {
    await SecureApiKeyStorage.clearAnthropicKey();
    _keyCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key removed from device')),
      );
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bring your own key (BYOK)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Your Anthropic key stays in the device keychain. It’s sent to your Supabase Edge Function over HTTPS — never stored in Postgres.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyCtrl,
            obscureText: _mask,
            decoration: InputDecoration(
              labelText: 'Anthropic API key',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _mask = !_mask),
                icon: Icon(_mask ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: _saving ? null : _saveKey,
                style: FilledButton.styleFrom(backgroundColor: AppPalette.primary),
                child: Text(_saving ? 'Saving…' : 'Save key'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _clearKey,
                child: const Text('Remove'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {mode},
            onSelectionChanged: (s) {
              ref.read(themeModeProvider.notifier).setTheme(s.first);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: System follows OS dark mode.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 28),
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          const SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Coaching reminders'),
            subtitle: Text('Local scheduling coming soon'),
            value: false,
            onChanged: null,
          ),
          const SizedBox(height: 16),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Export history'),
            subtitle: const Text('Use Supabase dashboard or add CSV export later'),
            trailing: OutlinedButton(
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: 'https://supabase.com/dashboard'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open your Supabase dashboard to export')),
                );
              },
              child: const Text('Copy link'),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
