import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../core/localization.dart';
import '../../services/barrel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool register}) async {
    final AppStrings s = context.read<LocalizationService>().strings;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    final AuthService auth = context.read<AuthService>();
    final VaultService vault = context.read<VaultService>();

    bool ok;
    if (register) {
      if (_password.text.length < 6) {
        setState(() {
          _busy = false;
          _error = s.t('passwordTooShort');
        });
        return;
      }
      ok = await auth.register(_username.text, _password.text);
    } else {
      ok = await auth.login(_password.text);
    }

    if (!mounted) return;

    if (ok) {
      vault.openVault('local', _password.text);
    } else {
      setState(() {
        _busy = false;
        _error = s.t('invalidCredentials');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalizationService l10n = context.watch<LocalizationService>();
    final AppStrings s = l10n.strings;
    final AuthService auth = context.watch<AuthService>();
    final bool hasAccount = auth.hasAccount;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.lock_person,
                      size: 72, color: Color(0xFF2A4B7C)),
                  const SizedBox(height: 16),
                  Text(
                    s.t('appTitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(s.t('tagline'), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (!hasAccount)
                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: s.t('username'),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? v) =>
                          (v == null || v.trim().isEmpty) ? '!' : null,
                    ),
                  if (!hasAccount) const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    onFieldSubmitted: (_) => _submit(register: !hasAccount),
                    decoration: InputDecoration(
                      labelText: s.t('password'),
                      prefixIcon: const Icon(Icons.key_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? '!' : null,
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  FilledButton(
                    onPressed: _busy ? null : () => _submit(register: !hasAccount),
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(hasAccount ? s.t('login') : s.t('register')),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: l10n.code,
                    isExpanded: true,
                    onChanged: (String? v) {
                      if (v != null) l10n.setLanguage(v);
                    },
                    items: AppStrings.supported
                        .map((String c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c.toUpperCase()),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
