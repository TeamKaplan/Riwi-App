import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  NotificationSettingsNotifier() : super(NotificationSettings());

  void toggleDailyReminders() {
    state = state.copyWith(dailyReminders: !state.dailyReminders);
  }

  void toggleLeagueRanking() {
    state = state.copyWith(leagueRanking: !state.leagueRanking);
  }

  void toggleAppUpdates() {
    state = state.copyWith(appUpdates: !state.appUpdates);
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});
