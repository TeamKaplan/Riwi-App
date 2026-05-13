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
  final String username;
  final DateTime? lastLessonDate;

  const ProgressState({
    this.completedLevels = const {0: {}, 1: {}, 2: {}},
    this.totalXP = 0,
    this.streak = 0,
    this.lessonsCompleted = 0,
    this.username = '',
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
    String? username,
    DateTime? lastLessonDate,
  }) {
    return ProgressState(
      completedLevels: completedLevels ?? this.completedLevels,
      totalXP: totalXP ?? this.totalXP,
      streak: streak ?? this.streak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      username: username ?? this.username,
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
        'username': username,
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
      username: json['username'] as String? ?? '',
      lastLessonDate: json['lastLessonDate'] != null
          ? DateTime.tryParse(json['lastLessonDate'] as String)
          : null,
    );
  }

  factory ProgressState.fromSupabase(Map<String, dynamic> row, Map<int, Set<int>> completed) {
    return ProgressState(
      completedLevels: completed,
      totalXP: (row['total_xp'] as num?)?.toInt() ?? 0,
      streak: (row['streak'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (row['lessons_completed'] as num?)?.toInt() ?? 0,
      username: row['username'] as String? ?? '',
      lastLessonDate: row['last_lesson_date'] != null
          ? DateTime.tryParse(row['last_lesson_date'] as String)
          : null,
    );
  }

  static Map<int, Set<int>> levelsFromRows(List<dynamic> rows) {
    Map<int, Set<int>> completed = {0: {}, 1: {}, 2: {}};
    for (var row in rows) {
      final courseId = (row['course_id'] as num).toInt();
      final levelId = (row['level_id'] as num).toInt();
      if (!completed.containsKey(courseId)) {
        completed[courseId] = {};
      }
      completed[courseId]!.add(levelId);
    }
    return completed;
  }

  Map<String, dynamic> toSupabase(String userId) => {
        'id': userId,
        'username': username,
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
        final loadedState = ProgressState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        // Bug #3 fix: Recalcular racha al cargar localmente
        final updatedStreak = _computeStreak(loadedState.streak, loadedState.lastLessonDate, DateTime.now());
        state = loadedState.copyWith(streak: updatedStreak);
      }
    } catch (e) {
      debugPrint('Error loading local progress: $e');
    }
  }

  Future<void> _loadFromSupabase(String userId) async {
    try {
      // 1. Cargar datos del perfil
      final profileData = await _supabase
          .from('profiles')
          .select('total_xp, streak, lessons_completed, last_lesson_date, username')
          .eq('id', userId)
          .maybeSingle();

      if (profileData != null) {
        // 2. Cargar niveles desde la nueva tabla relacional (Normalización 3FN)
        final levelsData = await _supabase
            .from('user_progress')
            .select('course_id, level_id')
            .eq('user_id', userId);

        final completed = ProgressState.levelsFromRows(levelsData);
        final loadedState = ProgressState.fromSupabase(profileData, completed);
        
        // Bug #3 fix: Recalcular racha al cargar de Supabase
        final updatedStreak = _computeStreak(loadedState.streak, loadedState.lastLessonDate, DateTime.now());
        state = loadedState.copyWith(streak: updatedStreak);
      } else {
        // Usuario nuevo sin perfil aún — intentar obtener nombre de Auth metadata
        final authUsername = _supabase.auth.currentUser?.userMetadata?['username'] as String? ?? 
                           _supabase.auth.currentUser?.email?.split('@').first ?? '';
        state = ProgressState(username: authUsername);
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

  Future<void> _saveToSupabase({int? newCourseId, int? newLevelId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Actualizar perfil (XP, racha, etc)
      await _supabase
          .from('profiles')
          .upsert(state.toSupabase(userId), onConflict: 'id');

      // 2. Si se completó un nivel, registrar en la tabla relacional
      if (newCourseId != null && newLevelId != null) {
        await _supabase.from('user_progress').upsert({
          'user_id': userId,
          'course_id': newCourseId,
          'level_id': newLevelId,
          'completed_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id, course_id, level_id');
      }
    } catch (e) {
      debugPrint('Error saving to Supabase: $e');
      rethrow;
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
    await _saveToSupabase(newCourseId: courseIndex, newLevelId: levelId);
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
