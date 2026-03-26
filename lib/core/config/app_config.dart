/// Compile-time configuration. Prefer release builds with:
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bedzbkyycuoiiyuzxejg.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZHpia3l5Y3VvaWl5dXp4ZWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MTcwNDMsImV4cCI6MjA4OTk5MzA0M30.pHuYB7IInLn0MFOLHjF0KZwLWsMzAxdIHDc8INynbn8',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('YOUR_PROJECT') &&
      supabaseAnonKey.isNotEmpty;
}

