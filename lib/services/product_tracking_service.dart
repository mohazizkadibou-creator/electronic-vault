import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks per-product download counters locally.
class ProductTrackingService extends ChangeNotifier {
  static const String _kPrefix = 'ev_downloads_';

  final SharedPreferences _prefs;

  ProductTrackingService(this._prefs);

  int countFor(String projectId, String productKey) {
    return _prefs.getInt('$_kPrefix$projectId::$productKey') ?? 0;
  }

  Future<void> recordDownload(String projectId, String productKey) async {
    final String key = '$_kPrefix$projectId::$productKey';
    final int current = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, current + 1);
    notifyListeners();
  }
}
