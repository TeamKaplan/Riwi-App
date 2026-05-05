import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/sound_provider.dart';

class SoundScreen extends ConsumerWidget {
  const SoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final settings = ref.watch(soundProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          isSpanish ? 'Sonidos' : 'Sounds',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildVolumeSection(
            context,
            title: isSpanish ? 'Volumen Maestro' : 'Master Volume',
            value: settings.masterVolume,
            icon: settings.isMuted ? Icons.volume_off : Icons.volume_up,
            onChanged: (val) => ref.read(soundProvider.notifier).setMasterVolume(val),
          ),
          const SizedBox(height: 32),
          _buildVolumeSection(
            context,
            title: isSpanish ? 'Música de fondo' : 'Background Music',
            value: settings.musicVolume,
            icon: Icons.music_note,
            onChanged: (val) => ref.read(soundProvider.notifier).setMusicVolume(val),
          ),
          const SizedBox(height: 32),
          _buildVolumeSection(
            context,
            title: isSpanish ? 'Efectos especiales' : 'Sound Effects',
            value: settings.effectsVolume,
            icon: Icons.auto_awesome,
            onChanged: (val) => ref.read(soundProvider.notifier).setEffectsVolume(val),
          ),
          const SizedBox(height: 40),
          // Mute switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: SwitchListTile(
              title: Text(
                isSpanish ? 'Silenciar todo' : 'Mute all',
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              value: settings.isMuted,
              onChanged: (_) => ref.read(soundProvider.notifier).toggleMute(),
              activeThumbColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSection(
    BuildContext context, {
    required String title,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withOpacity(0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
