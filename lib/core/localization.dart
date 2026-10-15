import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';

/// Holds the currently selected language and exposes [strings].
class LocalizationService extends ChangeNotifier {
  static const String _kLang = 'ev_language';

  final SharedPreferences _prefs;
  String _code;

  LocalizationService(this._prefs)
      : _code = _prefs.getString(_kLang) ?? 'en';

  AppStrings get strings => AppStrings(_code);
  String get code => _code;

  Future<void> setLanguage(String code) async {
    if (_code == code) return;
    _code = code;
    await _prefs.setString(_kLang, code);
    notifyListeners();
  }
}
