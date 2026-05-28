import 'package:flutter_test/flutter_test.dart';
import 'package:app_kaplan/core/providers/progress_provider.dart';

void main() {
  // ── isLevelCompleted ──────────────────────────────────────────────────────
  group('ProgressState.isLevelCompleted', () {
    test('false en estado inicial vacío', () {
      expect(ProgressState().isLevelCompleted(0, 1), false);
    });

    test('true cuando el nivel está en completedLevels', () {
      final s = ProgressState(completedLevels: {0: {1, 2, 3}, 1: {}, 2: {}});
      expect(s.isLevelCompleted(0, 1), true);
      expect(s.isLevelCompleted(0, 2), true);
      expect(s.isLevelCompleted(0, 3), true);
    });

    test('false para nivel no completado en el mismo curso', () {
      final s = ProgressState(completedLevels: {0: {1, 2}, 1: {}, 2: {}});
      expect(s.isLevelCompleted(0, 3), false);
    });

    test('false para curso diferente', () {
      final s = ProgressState(completedLevels: {0: {1}, 1: {}, 2: {}});
      expect(s.isLevelCompleted(1, 1), false);
    });
  });

  // ── currentLevel ─────────────────────────────────────────────────────────
  group('ProgressState.currentLevel', () {
    test('retorna 1 cuando no hay nada completado', () {
      expect(ProgressState().currentLevel(0), 1);
    });

    test('retorna maxId + 1 cuando hay niveles completados', () {
      final s = ProgressState(completedLevels: {0: {1, 2, 3}, 1: {}, 2: {}});
      expect(s.currentLevel(0), 4);
    });

    test('funciona correctamente con completados no consecutivos', () {
      final s = ProgressState(completedLevels: {0: {1, 3, 5}, 1: {}, 2: {}});
      expect(s.currentLevel(0), 6); // max es 5, siguiente es 6
    });

    test('cursos independientes no se afectan entre sí', () {
      final s = ProgressState(completedLevels: {0: {1, 2}, 1: {1}, 2: {}});
      expect(s.currentLevel(0), 3);
      expect(s.currentLevel(1), 2);
      expect(s.currentLevel(2), 1);
    });
  });

  // ── isLevelUnlocked ───────────────────────────────────────────────────────
  group('ProgressState.isLevelUnlocked', () {
    test('nivel 1 siempre desbloqueado', () {
      expect(ProgressState().isLevelUnlocked(0, 1), true);
    });

    test('nivel 2 bloqueado si no se completó el nivel 1', () {
      expect(ProgressState().isLevelUnlocked(0, 2), false);
    });

    test('nivel 2 desbloqueado después de completar el nivel 1', () {
      final s = ProgressState(completedLevels: {0: {1}, 1: {}, 2: {}});
      expect(s.isLevelUnlocked(0, 2), true);
    });

    test('nivel 5 bloqueado si solo se completó hasta el 3', () {
      final s = ProgressState(completedLevels: {0: {1, 2, 3}, 1: {}, 2: {}});
      expect(s.isLevelUnlocked(0, 4), true);
      expect(s.isLevelUnlocked(0, 5), false);
    });
  });

  // ── copyWith ─────────────────────────────────────────────────────────────
  group('ProgressState.copyWith', () {
    test('copia todos los valores si no se especifican', () {
      final original = ProgressState(totalXP: 100, streak: 3, lessonsCompleted: 2);
      final copy = original.copyWith();
      expect(copy.totalXP, 100);
      expect(copy.streak, 3);
      expect(copy.lessonsCompleted, 2);
    });

    test('sobreescribe solo los valores especificados', () {
      final original = ProgressState(totalXP: 100, streak: 3);
      final copy = original.copyWith(totalXP: 200);
      expect(copy.totalXP, 200);
      expect(copy.streak, 3); // sin cambio
    });
  });

  // ── toJson / fromJson roundtrip ────────────────────────────────────────────
  group('ProgressState JSON roundtrip', () {
    test('serializa y deserializa XP, racha y lecciones', () {
      final original = ProgressState(
        totalXP: 350,
        streak: 7,
        lessonsCompleted: 5,
        username: 'TestUser',
      );
      final restored = ProgressState.fromJson(original.toJson());
      expect(restored.totalXP, 350);
      expect(restored.streak, 7);
      expect(restored.lessonsCompleted, 5);
      expect(restored.username, 'TestUser');
    });

    test('serializa y deserializa niveles completados correctamente', () {
      final original = ProgressState(
        completedLevels: {0: {1, 2, 3}, 1: {1}, 2: {1, 2}},
      );
      final restored = ProgressState.fromJson(original.toJson());
      expect(restored.completedLevels[0], containsAll([1, 2, 3]));
      expect(restored.completedLevels[1], contains(1));
      expect(restored.completedLevels[2], containsAll([1, 2]));
    });

    test('serializa y deserializa lastLessonDate', () {
      final date = DateTime(2026, 5, 28);
      final original = ProgressState(lastLessonDate: date);
      final restored = ProgressState.fromJson(original.toJson());
      expect(restored.lastLessonDate?.year, 2026);
      expect(restored.lastLessonDate?.month, 5);
      expect(restored.lastLessonDate?.day, 28);
    });

    test('maneja correctamente lastLessonDate null', () {
      final original = ProgressState();
      final restored = ProgressState.fromJson(original.toJson());
      expect(restored.lastLessonDate, isNull);
    });
  });

  // ── levelsFromRows ────────────────────────────────────────────────────────
  group('ProgressState.levelsFromRows', () {
    test('construye el mapa de niveles completados desde filas de Supabase', () {
      final rows = [
        {'course_id': 0, 'level_id': 1},
        {'course_id': 0, 'level_id': 2},
        {'course_id': 1, 'level_id': 1},
      ];
      final result = ProgressState.levelsFromRows(rows);
      expect(result[0], containsAll([1, 2]));
      expect(result[1], contains(1));
      expect(result[2], isEmpty);
    });

    test('retorna mapa vacío cuando no hay filas', () {
      final result = ProgressState.levelsFromRows([]);
      expect(result[0], isEmpty);
      expect(result[1], isEmpty);
      expect(result[2], isEmpty);
    });
  });
}
