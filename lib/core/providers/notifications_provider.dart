import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool dailyReminders;
  final bool leagueRanking;
  final bool appUpdates;

  NotificationSettings({
    this.dailyReminders = true,
    this.leagueRanking = true,
    this.appUpdates = false,
  });

  NotificationSettings copyWith({
    bool? dailyReminders,
    bool? leagueRanking,
    bool? appUpdates,
  }) {
    return NotificationSettings(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      leagueRanking: leagueRanking ?? this.leagueRanking,
      appUpdates: appUpdates ?? this.appUpdates,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const _key = 'kaplan_notification_settings';

  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final daily = prefs.getBool('${_key}_daily');
      final league = prefs.getBool('${_key}_league');
      final updates = prefs.getBool('${_key}_updates');

      if (daily != null || league != null || updates != null) {
        state = state.copyWith(
          dailyReminders: daily,
          leagueRanking: league,
          appUpdates: updates,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_key}_daily', state.dailyReminders);
      await prefs.setBool('${_key}_league', state.leagueRanking);
      await prefs.setBool('${_key}_updates', state.appUpdates);
    } catch (_) {}
  }

  void toggleDailyReminders() {
    state = state.copyWith(dailyReminders: !state.dailyReminders);
    _saveSettings();
  }

  void toggleLeagueRanking() {
    state = state.copyWith(leagueRanking: !state.leagueRanking);
    _saveSettings();
  }

  void toggleAppUpdates() {
    state = state.copyWith(appUpdates: !state.appUpdates);
    _saveSettings();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});
