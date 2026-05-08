import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_provider.dart';

final progressProvider = StateNotifierProvider<ProgressNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  // Return default progress without requiring authentication for web demo
  return ProgressNotifier(null);
});

class ProgressNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final String? userId;
  final _supabase = Supabase.instance.client;

  ProgressNotifier(this.userId) : super(const AsyncValue.loading()) {
    if (userId != null) {
      _loadProgress();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _loadProgress() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('xp, streak, full_name, avatar_url')
          .eq('id', userId!)
          .single();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addXp(int amount) async {
    if (userId == null) return;
    
    final currentData = state.value;
    final currentXp = currentData?['xp'] ?? 0;
    final newXp = currentXp + amount;
    
    // Update local state immediately for fast UI
    if (currentData != null) {
      state = AsyncValue.data({...currentData, 'xp': newXp});
    }

    // Persist to Supabase
    try {
      await _supabase
          .from('profiles')
          .update({'xp': newXp})
          .eq('id', userId!);
    } catch (e) {
      // Revert if error
      state = AsyncValue.data(currentData);
    }
  }

  Future<void> updateStreak() async {
    if (userId == null) return;
    // Basic streak update logic for demonstration
    // Usually, you check last_login_date to see if you should increment or reset
    final currentData = state.value;
    final currentStreak = currentData?['streak'] ?? 0;
    final newStreak = currentStreak + 1;
    
    if (currentData != null) {
      state = AsyncValue.data({...currentData, 'streak': newStreak});
    }

    try {
      await _supabase
          .from('profiles')
          .update({'streak': newStreak})
          .eq('id', userId!);
    } catch (e) {
      state = AsyncValue.data(currentData);
    }
  }
}
