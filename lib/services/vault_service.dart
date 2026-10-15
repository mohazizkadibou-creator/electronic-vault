import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Manages the unlocked/locked state of the vault and provides
/// AES-256-GCM encryption helpers backed by a passphrase.
class VaultService extends ChangeNotifier {
  bool _isOpen = false;
  String? _vaultId;
  String? _passphrase;

  bool get isVaultOpen => _isOpen;
  String? get vaultId => _vaultId;

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) async {
    final Pbkdf2 pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  /// Encrypts [plaintext] and returns a self-contained JSON envelope string.
  Future<String> encryptString(
      String plaintext, String passphrase, String saltB64) async {
    final SecretKey key = await _deriveKey(passphrase, base64Decode(saltB64));
    final AesGcm algorithm = AesGcm.with256bits();
    final List<int> nonce = algorithm.newNonce();
    final SecretBox box = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );
    return jsonEncode(<String, dynamic>{
      'v': 1,
      'n': base64Encode(box.nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    });
  }

  /// Decrypts an envelope produced by [encryptString].
  Future<String> decryptString(
      String envelope, String passphrase, String saltB64) async {
    final Map<String, dynamic> data =
        jsonDecode(envelope) as Map<String, dynamic>;
    final SecretKey key = await _deriveKey(passphrase, base64Decode(saltB64));
    final AesGcm algorithm = AesGcm.with256bits();
    final SecretBox box = SecretBox(
      base64Decode(data['c'] as String),
      nonce: base64Decode(data['n'] as String),
      mac: Mac(base64Decode(data['m'] as String)),
    );
    final List<int> clear = await algorithm.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }

  void openVault(String vaultId, String passphrase) {
    _vaultId = vaultId;
    _passphrase = passphrase;
    _isOpen = true;
    notifyListeners();
  }

  void lockVault() {
    _isOpen = false;
    _passphrase = null;
    notifyListeners();
  }

  String? get passphrase => _passphrase;
}
