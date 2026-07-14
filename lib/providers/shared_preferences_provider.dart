import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final activeBusinessIdProvider =
    StateNotifierProvider<ActiveBusinessIdNotifier, int?>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ActiveBusinessIdNotifier(prefs);
    });

final isGstEnabledProvider = StateNotifierProvider<GstEnabledNotifier, bool>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GstEnabledNotifier(prefs);
});

final reminderNotificationsEnabledProvider =
    StateNotifierProvider<ReminderNotificationsEnabledNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ReminderNotificationsEnabledNotifier(prefs);
    });

final reminderNotificationOffsetsProvider =
    StateNotifierProvider<ReminderNotificationOffsetsNotifier, List<int>>((
      ref,
    ) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ReminderNotificationOffsetsNotifier(prefs);
    });

final lowStockWarningsEnabledProvider =
    StateNotifierProvider<LowStockWarningsEnabledNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return LowStockWarningsEnabledNotifier(prefs);
    });

final printBankDetailsOnInvoiceProvider =
    StateNotifierProvider<PrintBankDetailsOnInvoiceNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return PrintBankDetailsOnInvoiceNotifier(prefs);
    });

final autoBackupEnabledProvider =
    StateNotifierProvider<AutoBackupEnabledNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AutoBackupEnabledNotifier(prefs);
    });

class ActiveBusinessIdNotifier extends StateNotifier<int?> {
  final SharedPreferences _prefs;
  static const _key = 'active_business_id';

  ActiveBusinessIdNotifier(this._prefs) : super(_prefs.getInt(_key));

  void setActiveBusinessId(int id) {
    state = id;
    _prefs.setInt(_key, id);
  }

  void clearActiveBusiness() {
    state = null;
    _prefs.remove(_key);
  }
}

class GstEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'is_gst_enabled';

  // Default to true for backward compatibility
  GstEnabledNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  void setGstEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_key, enabled);
  }
}

class ReminderNotificationsEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'reminder_notifications_enabled';

  ReminderNotificationsEnabledNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? true);

  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_key, enabled);
  }
}

class ReminderNotificationOffsetsNotifier extends StateNotifier<List<int>> {
  final SharedPreferences _prefs;
  static const _key = 'reminder_notification_offsets';
  static const List<int> _defaultOffsets = [-7, -3, -1, 0, 1, 3];

  ReminderNotificationOffsetsNotifier(this._prefs)
    : super(_readOffsets(_prefs));

  static List<int> _readOffsets(SharedPreferences prefs) {
    final raw = prefs.getStringList(_key);
    if (raw == null || raw.isEmpty) return _defaultOffsets;
    final parsed = raw.map(int.tryParse).whereType<int>().toSet().toList()
      ..sort();
    return parsed.isEmpty ? _defaultOffsets : parsed;
  }

  void setOffsets(List<int> offsets) {
    final sanitized = offsets.toSet().toList()..sort();
    state = sanitized;
    _prefs.setStringList(
      _key,
      sanitized.map((value) => value.toString()).toList(),
    );
  }
}

class LowStockWarningsEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'low_stock_warnings_enabled';

  LowStockWarningsEnabledNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? true);

  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_key, enabled);
  }
}

class PrintBankDetailsOnInvoiceNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'print_bank_details_on_invoice';

  PrintBankDetailsOnInvoiceNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? false);

  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_key, enabled);
  }
}

class AutoBackupEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'auto_backup_enabled';

  AutoBackupEnabledNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? false);

  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_key, enabled);
  }
}
