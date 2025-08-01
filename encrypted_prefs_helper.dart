import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class EncryptedPrefsHelper {
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  static const String lastFlightKey = 'last_flight';
  static const String lastReservationKey = 'last_reservation';
  static const String lastCustomerKey = 'last_customer';
  static const String lastAirplaneKey = 'last_airplane';

  Future<void> saveLast(String key, Map<String, String> values) async {
    for (final entry in values.entries) {
      await _prefs.setString('${key}_${entry.key}', entry.value);
    }
    await appendHistory(key, values);
  }

  Future<Map<String, String>> loadLast(String key, List<String> fields) async {
    final result = <String, String>{};
    for (final field in fields) {
      result[field] = await _prefs.getString('${key}_$field') ?? '';
    }
    return result;
  }

  Future<void> appendHistory(String key, Map<String, String> values) async {
    final raw = await _prefs.getString('${key}_history') ?? '[]';
    final List entries = jsonDecode(raw);
    entries.add({
      'timestamp': DateTime.now().toIso8601String(),
      'values': values,
    });
    if (entries.length > 20) entries.removeAt(0);
    await _prefs.setString('${key}_history', jsonEncode(entries));
  }

  Future<List<Map<String, String>>> loadHistory(String key, Duration maxAge) async {
    final raw = await _prefs.getString('${key}_history') ?? '[]';
    final List entries = jsonDecode(raw);
    final cutoff = DateTime.now().subtract(maxAge);
    final result = <Map<String, String>>[];
    for (final e in entries.reversed) {
      final ts = DateTime.tryParse(e['timestamp'] as String);
      if (ts != null && ts.isAfter(cutoff)) {
        final vals = Map<String, String>.from(e['values'] as Map);
        result.add(vals);
      }
    }
    return result;
  }
}
