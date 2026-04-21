import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Anthropic API key (BYOK) — device keystore / keychain only.
abstract final class SecureApiKeyStorage {
  static const _kAnthropicKey = 'sb_secret_1Kakejxm6d2S0ANDSDngqA_ttDvukXX';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveAnthropicKey(String key) =>
      _storage.write(key: _kAnthropicKey, value: key.trim());

  static Future<String?> readAnthropicKey() => _storage.read(key: _kAnthropicKey);

  static Future<void> clearAnthropicKey() => _storage.delete(key: _kAnthropicKey);
}
