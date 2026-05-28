import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/learning/data/models/level_model.dart';
import '../../features/learning/data/models/question_model.dart';
import '../../features/learning/data/levels/english_levels.dart';
import '../../features/learning/data/levels/development_levels.dart';
import '../../features/learning/data/levels/soft_skills_levels.dart';

class LevelsService {
  static final _client = Supabase.instance.client;

  static List<Level> localLevels(int courseIndex) {
    switch (courseIndex) {
      case 0:  return EnglishLevels.getAllLevels();
      case 1:  return DevelopmentLevels.getAllLevels();
      case 2:  return SoftSkillsLevels.getAllLevels();
      default: return [];
    }
  }

  /// Retorna niveles desde Supabase. Si la tabla está vacía, hace seed automático
  /// y devuelve los datos locales. Si Supabase falla, devuelve locales como fallback.
  static Future<List<Level>> getLevels(int courseIndex) async {
    try {
      final rows = await _client
          .from('levels')
          .select('*, questions(*)')
          .eq('course_id', courseIndex)
          .order('level_number');

      if (rows.isEmpty) {
        debugPrint('LevelsService: DB vacía para curso $courseIndex, iniciando seed...');
        await seedCourse(courseIndex);
        return localLevels(courseIndex);
      }

      return rows.map<Level>(_levelFromMap).toList();
    } catch (e) {
      debugPrint('LevelsService: fallback local — $e');
      return localLevels(courseIndex);
    }
  }

  static Level _levelFromMap(Map<String, dynamic> m) {
    final questionsRaw = (m['questions'] as List?) ?? [];
    final sorted = List<Map<String, dynamic>>.from(questionsRaw)
      ..sort((a, b) => (a['order_index'] as int).compareTo(b['order_index'] as int));

    return Level(
      id:          m['level_number'] as int,
      title:       m['title'] as String,
      description: m['description'] as String? ?? '',
      difficulty:  m['difficulty'] as String? ?? 'Básico',
      xpReward:    m['xp_reward'] as int? ?? 100,
      exercises:   sorted.map(_questionFromMap).toList(),
    );
  }

  static Question _questionFromMap(Map<String, dynamic> m) {
    final type = QuestionType.values.firstWhere(
      (t) => t.name == m['question_type'],
      orElse: () => QuestionType.multipleChoice,
    );

    List<QuestionOption>? options;
    if (m['options'] != null) {
      options = (m['options'] as List).map((o) {
        final opt = o as Map<String, dynamic>;
        return QuestionOption(
          text:      opt['text'] as String,
          isCorrect: opt['isCorrect'] as bool? ?? false,
        );
      }).toList();
    }

    return Question(
      id:            m['id'] as String,
      type:          type,
      prompt:        m['prompt'] as String,
      instruction:   m['instruction'] as String?,
      correctAnswer: m['correct_answer'] as String?,
      options:       options,
      matchingLeft:  m['matching_left'] != null  ? List<String>.from(m['matching_left'])  : null,
      matchingRight: m['matching_right'] != null ? List<String>.from(m['matching_right']) : null,
      blanksAnswers: m['blanks_answers'] != null ? List<String>.from(m['blanks_answers']) : null,
      readingText:   m['reading_text'] as String?,
      codeSnippet:   m['code_snippet'] as String?,
      codeLanguage:  m['code_language'] as String?,
    );
  }

  /// Sube todos los niveles y preguntas locales de un curso a Supabase.
  /// Usa upsert para ser idempotente (se puede ejecutar múltiples veces sin duplicar).
  static Future<void> seedCourse(int courseIndex) async {
    final levels = localLevels(courseIndex);

    for (final level in levels) {
      try {
        final result = await _client
            .from('levels')
            .upsert({
              'course_id':    courseIndex,
              'level_number': level.id,
              'title':        level.title,
              'description':  level.description,
              'difficulty':   level.difficulty,
              'xp_reward':    level.xpReward,
            }, onConflict: 'course_id,level_number')
            .select('id')
            .single();

        final levelId = result['id'] as int;

        for (int i = 0; i < level.exercises.length; i++) {
          final q = level.exercises[i];
          await _client.from('questions').upsert({
            'id':            q.id,
            'level_id':      levelId,
            'question_type': q.type.name,
            'prompt':        q.prompt,
            'instruction':   q.instruction,
            'correct_answer':q.correctAnswer,
            'options':       q.options?.map((o) => {'text': o.text, 'isCorrect': o.isCorrect}).toList(),
            'matching_left': q.matchingLeft,
            'matching_right':q.matchingRight,
            'blanks_answers':q.blanksAnswers,
            'reading_text':  q.readingText,
            'code_snippet':  q.codeSnippet,
            'code_language': q.codeLanguage,
            'order_index':   i,
          }, onConflict: 'id');
        }
        debugPrint('LevelsService: nivel ${level.id} del curso $courseIndex cargado.');
      } catch (e) {
        debugPrint('LevelsService: error seed nivel ${level.id} — $e');
      }
    }
  }

  /// Seed de todos los cursos. Llamar una sola vez desde la pantalla de administración.
  static Future<void> seedAllCourses() async {
    for (int i = 0; i < 3; i++) {
      await seedCourse(i);
    }
  }
}
