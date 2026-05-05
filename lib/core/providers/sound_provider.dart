import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  SoundSettingsNotifier() : super(SoundSettings());

  void setMasterVolume(double value) {
    state = state.copyWith(masterVolume: value);
  }

  void setMusicVolume(double value) {
    state = state.copyWith(musicVolume: value);
  }

  void setEffectsVolume(double value) {
    state = state.copyWith(effectsVolume: value);
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }
}

final soundProvider = StateNotifierProvider<SoundSettingsNotifier, SoundSettings>((ref) {
  return SoundSettingsNotifier();
});
