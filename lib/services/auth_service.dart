import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local, single-user authentication for the vault.
///
/// The password is never stored. Instead an Argon2id hash of the password is
/// kept together with a random per-install salt. No data ever leaves the
/// device.
class AuthService extends ChangeNotifier {
  static const String _kUsername = 'ev_username';
  static const String _kHash = 'ev_password_hash';
  static const String _kSalt = 'ev_salt';
  static const String _kLoggedIn = 'ev_logged_in';

  final SharedPreferences _prefs;
  bool _isLoggedIn = false;
  String? _username;

  AuthService(this._prefs) {
    _isLoggedIn = _prefs.getBool(_kLoggedIn) ?? false;
    _username = _prefs.getString(_kUsername);
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  bool get hasAccount => _prefs.getString(_kHash) != null;

  /// The salt used to derive the vault encryption key (base64) if registered.
  String? get vaultSalt => _prefs.getString(_kSalt);

  List<int> _randomBytes(int length) {
    final Random secure = Random.secure();
    return List<int>.generate(length, (_) => secure.nextInt(256));
  }

  Future<List<int>> _derive(
      String password, List<int> salt, String username) async {
    final Argon2id algorithm = Argon2id(
      memory: 65536,
      parallelism: 2,
      iterations: 3,
      hashLength: 32,
    );
    final SecretKey key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode('$username\u0000$password')),
      nonce: salt,
    );
    return key.extractBytes();
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  Future<bool> register(String username, String password) async {
    final String trimmed = username.trim();
    if (trimmed.isEmpty || password.length < 6) return false;

    final List<int> salt = _randomBytes(16);
    final List<int> hash = await _derive(password, salt, trimmed);

    await _prefs.setString(_kUsername, trimmed);
    await _prefs.setString(_kSalt, base64Encode(salt));
    await _prefs.setString(_kHash, base64Encode(hash));
    await _prefs.setBool(_kLoggedIn, true);

    _username = trimmed;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  Future<bool> login(String password) async {
    final String? username = _prefs.getString(_kUsername);
    final String? saltB64 = _prefs.getString(_kSalt);
    final String? hashB64 = _prefs.getString(_kHash);
    if (username == null || saltB64 == null || hashB64 == null) return false;

    final List<int> salt = base64Decode(saltB64);
    final List<int> expected = base64Decode(hashB64);
    final List<int> actual = await _derive(password, salt, username);

    final bool ok = _constantTimeEquals(actual, expected);
    if (ok) {
      _isLoggedIn = true;
      await _prefs.setBool(_kLoggedIn, true);
      notifyListeners();
    }
    return ok;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs.setBool(_kLoggedIn, false);
    notifyListeners();
  }
}
