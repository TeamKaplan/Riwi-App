import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressState {
  final Map<int, Set<int>> completedLevels;
  final int totalXP;
  final int streak;
  final int lessonsCompleted;
  final DateTime? lastLessonDate;

  const ProgressState({
    this.completedLevels = const {0: {}, 1: {}, 2: {}},
    this.totalXP = 0,
    this.streak = 0,
    this.lessonsCompleted = 0,
    this.lastLessonDate,
  });

  bool isLevelCompleted(int courseIndex, int levelId) =>
      completedLevels[courseIndex]?.contains(levelId) ?? false;

  int currentLevel(int courseIndex) {
    final completed = completedLevels[courseIndex];
    if (completed == null || completed.isEmpty) return 1;
    return completed.reduce((a, b) => a > b ? a : b) + 1;
  }

  bool isLevelUnlocked(int courseIndex, int levelId) =>
      levelId <= currentLevel(courseIndex);

  ProgressState copyWith({
    Map<int, Set<int>>? completedLevels,
    int? totalXP,
    int? streak,
    int? lessonsCompleted,
    DateTime? lastLessonDate,
  }) {
    return ProgressState(
      completedLevels: completedLevels ?? this.completedLevels,
      totalXP: totalXP ?? this.totalXP,
      streak: streak ?? this.streak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      lastLessonDate: lastLessonDate ?? this.lastLessonDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedLevels': completedLevels.map(
          (k, v) => MapEntry(k.toString(), v.toList()),
        ),
        'totalXP': totalXP,
        'streak': streak,
        'lessonsCompleted': lessonsCompleted,
        'lastLessonDate': lastLessonDate?.toIso8601String(),
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) {
    final raw = json['completedLevels'] as Map<String, dynamic>? ?? {};
    final completed = raw.map((k, v) =>
        MapEntry(int.parse(k), Set<int>.from((v as List).map((e) => e as int))));
    return ProgressState(
      completedLevels: {0: {}, 1: {}, 2: {}, ...completed},
      totalXP: json['totalXP'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      lastLessonDate: json['lastLessonDate'] != null
          ? DateTime.tryParse(json['lastLessonDate'] as String)
          : null,
    );
  }

  factory ProgressState.fromSupabase(Map<String, dynamic> row) {
    final rawLevels = row['completed_levels'];
    Map<int, Set<int>> completed = {0: {}, 1: {}, 2: {}};
    if (rawLevels != null) {
      final decoded = rawLevels is String
          ? jsonDecode(rawLevels) as Map<String, dynamic>
          : rawLevels as Map<String, dynamic>;
      completed = decoded.map((k, v) =>
          MapEntry(int.parse(k), Set<int>.from((v as List).map((e) => e as int))));
      for (int i = 0; i < 3; i++) {
        completed.putIfAbsent(i, () => {});
      }
    }
    return ProgressState(
      completedLevels: completed,
      totalXP: (row['total_xp'] as num?)?.toInt() ?? 0,
      streak: (row['streak'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (row['lessons_completed'] as num?)?.toInt() ?? 0,
      lastLessonDate: row['last_lesson_date'] != null
          ? DateTime.tryParse(row['last_lesson_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toSupabase(String userId) => {
        'id': userId,
        'completed_levels': jsonEncode(
          completedLevels.map((k, v) => MapEntry(k.toString(), v.toList())),
        ),
        'total_xp': totalXP,
        'streak': streak,
        'lessons_completed': lessonsCompleted,
        'last_lesson_date': lastLessonDate?.toIso8601String(),
      };
}

// ─── Lógica de racha ──────────────────────────────────────────────────────────
int _computeStreak(int currentStreak, DateTime? lastDate, DateTime today) {
  if (lastDate == null) return 1;

  final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  final diff = todayDay.difference(lastDay).inDays;

  if (diff == 0) return currentStreak;       // ya jugó hoy → sin cambio
  if (diff == 1) return currentStreak + 1;   // ayer → continúa
  return 1;                                  // 2+ días → resetea
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class ProgressNotifier extends StateNotifier<ProgressState> {
  final _supabase = Supabase.instance.client;

  ProgressNotifier() : super(const ProgressState()) {
    _init();
  }

  String _localKey(String userId) => 'kaplan_progress_$userId';

  Future<void> _init() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      state = const ProgressState();
      return;
    }
    await _loadLocal(userId);
    await _loadFromSupabase(userId);
  }

  Future<void> _loadLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey(userId));
      if (raw != null) {
        state = ProgressState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading local progress: $e');
    }
  }

  Future<void> _loadFromSupabase(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('total_xp, streak, lessons_completed, completed_levels, last_lesson_date')
          .eq('id', userId)
          .maybeSingle();
      if (data != null) {
        state = ProgressState.fromSupabase(data);
      } else {
        // Usuario nuevo sin perfil aún
        state = const ProgressState();
      }
      await _saveLocal(userId);
    } catch (e) {
      debugPrint('Error loading Supabase progress: $e');
    }
  }

  Future<void> _saveLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localKey(userId), jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Error saving local: $e');
    }
  }

  Future<void> _saveToSupabase() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      // Bug #1 fix: use upsert which handles INSERT + UPDATE atomically,
      // guaranteeing the profiles row is created even if the DB trigger failed.
      await _supabase
          .from('profiles')
          .upsert(state.toSupabase(userId), onConflict: 'id');
    } catch (e) {
      debugPrint('Full upsert failed ($e), trying minimal update...');
      try {
        await _supabase.from('profiles').update({
          'total_xp': state.totalXP,
          'streak': state.streak,
          'lessons_completed': state.lessonsCompleted,
        }).eq('id', userId);
      } catch (e2) {
        debugPrint('Minimal update also failed: $e2');
        rethrow; // Re-throw so the caller (completeLevel) can surface the error.
      }
    }
  }

  Future<void> completeLevel(int courseIndex, int levelId, int xpReward) async {
    final alreadyDone = state.isLevelCompleted(courseIndex, levelId);
    final today = DateTime.now();

    final updated = Map<int, Set<int>>.from(
      state.completedLevels.map((k, v) => MapEntry(k, Set<int>.from(v))),
    );
    updated[courseIndex] = {...(updated[courseIndex] ?? {}), levelId};

    final newStreak = _computeStreak(state.streak, state.lastLessonDate, today);

    state = state.copyWith(
      completedLevels: updated,
      totalXP: alreadyDone ? state.totalXP : state.totalXP + xpReward,
      streak: newStreak,
      lessonsCompleted:
          alreadyDone ? state.lessonsCompleted : state.lessonsCompleted + 1,
      lastLessonDate: today,
    );

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) await _saveLocal(userId);
    await _saveToSupabase();
  }

  /// Llamar tras login exitoso para cargar el progreso del usuario recién autenticado.
  Future<void> onLogin() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    state = const ProgressState();
    await _loadLocal(userId);
    await _loadFromSupabase(userId);
  }

  /// Llamar al cerrar sesión para limpiar el estado en memoria.
  void onLogout() {
    state = const ProgressState();
  }

  Future<void> reset() async {
    state = const ProgressState();
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) await _saveLocal(userId);
    await _saveToSupabase();
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(),
);
