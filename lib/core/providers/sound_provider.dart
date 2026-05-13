import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  final double masterVolume;
  final double musicVolume;
  final double effectsVolume;
  final bool isMuted;

  SoundSettings({
    this.masterVolume = 0.8,
    this.musicVolume = 0.6,
    this.effectsVolume = 0.9,
    this.isMuted = false,
  });

  SoundSettings copyWith({
    double? masterVolume,
    double? musicVolume,
    double? effectsVolume,
    bool? isMuted,
  }) {
    return SoundSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      effectsVolume: effectsVolume ?? this.effectsVolume,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class SoundSettingsNotifier extends StateNotifier<SoundSettings> {
  static const _key = 'kaplan_sound_settings';

  SoundSettingsNotifier() : super(SoundSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final master = prefs.getDouble('${_key}_master');
      final music = prefs.getDouble('${_key}_music');
      final effects = prefs.getDouble('${_key}_effects');
      final muted = prefs.getBool('${_key}_muted');

      if (master != null || music != null || effects != null || muted != null) {
        state = state.copyWith(
          masterVolume: master,
          musicVolume: music,
          effectsVolume: effects,
          isMuted: muted,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('${_key}_master', state.masterVolume);
      await prefs.setDouble('${_key}_music', state.musicVolume);
      await prefs.setDouble('${_key}_effects', state.effectsVolume);
      await prefs.setBool('${_key}_muted', state.isMuted);
    } catch (_) {}
  }

  void setMasterVolume(double value) {
    state = state.copyWith(masterVolume: value);
    _saveSettings();
  }

  void setMusicVolume(double value) {
    state = state.copyWith(musicVolume: value);
    _saveSettings();
  }

  void setEffectsVolume(double value) {
    state = state.copyWith(effectsVolume: value);
    _saveSettings();
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
    _saveSettings();
  }
}

final soundProvider = StateNotifierProvider<SoundSettingsNotifier, SoundSettings>((ref) {
  return SoundSettingsNotifier();
});
