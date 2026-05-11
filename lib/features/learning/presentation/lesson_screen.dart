import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/levels/english_levels.dart';
import '../data/levels/development_levels.dart';
import '../data/levels/soft_skills_levels.dart';
import '../data/models/level_model.dart';
import '../data/models/question_model.dart';
import '../../../core/providers/progress_provider.dart';

// ─────────────────────────────────────────────
//  PANTALLA PRINCIPAL
// ─────────────────────────────────────────────
class LessonScreen extends ConsumerStatefulWidget {
  final int courseIndex;
  final int levelId;

  const LessonScreen({super.key, required this.courseIndex, required this.levelId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late final Level? _level;
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _answered = false;
  bool _isCorrect = false;

  // Estado por tipo de pregunta
  String? _selectedOption;
  String? _tfAnswer;
  final List<TextEditingController> _blanksCtrls = [];
  // Matching
  int? _matchSelectedLeft;
  Map<int, int> _matchPairs = {};
  List<int> _matchRightOrder = [];

  @override
  void initState() {
    super.initState();
    _level = _loadLevel();
    _prepareQuestion();
  }

  Level? _loadLevel() {
    final List<Level> levels;
    switch (widget.courseIndex) {
      case 0:
        levels = EnglishLevels.getAllLevels();
        break;
      case 1:
        levels = DevelopmentLevels.getAllLevels();
        break;
      case 2:
        levels = SoftSkillsLevels.getAllLevels();
        break;
      default:
        levels = EnglishLevels.getAllLevels();
    }
    try {
      return levels.firstWhere((l) => l.id == widget.levelId);
    } catch (_) {
      return levels.isNotEmpty ? levels.first : null;
    }
  }

  void _prepareQuestion() {
    final level = _level;
    if (level == null || level.exercises.isEmpty) return;
    final q = level.exercises[_currentIndex];

    for (final c in _blanksCtrls) { c.dispose(); }
    _blanksCtrls.clear();
    _selectedOption = null;
    _tfAnswer = null;
    _matchSelectedLeft = null;
    _matchPairs = {};

    switch (q.type) {
      case QuestionType.fillInTheBlanks:
      case QuestionType.completeDialogue:
        final count = q.blanksAnswers?.length ?? _countBlanks(q.instruction ?? '');
        for (int i = 0; i < count; i++) { _blanksCtrls.add(TextEditingController()); }
        break;
      case QuestionType.completeCode:
        final count = q.blanksAnswers?.length ?? _countBlanks(q.codeSnippet ?? '');
        for (int i = 0; i < count; i++) { _blanksCtrls.add(TextEditingController()); }
        break;
      case QuestionType.completeWord:
      case QuestionType.orderWords:
      case QuestionType.errorCorrection:
      case QuestionType.shortWriting:
        _blanksCtrls.add(TextEditingController());
        break;
      case QuestionType.miniReading:
        if (q.options == null || q.options!.isEmpty) {
          _blanksCtrls.add(TextEditingController());
        }
        break;
      case QuestionType.matching:
        final right = q.matchingRight ?? [];
        _matchRightOrder = List.generate(right.length, (i) => i)..shuffle(Random(42));
        break;
      default:
        break;
    }
  }

  int _countBlanks(String text) => '___'.allMatches(text).length;

  Question get _currentQuestion => _level!.exercises[_currentIndex];
  int get _total => _level?.exercises.length ?? 1;

  bool get _canSubmit {
    if (_answered) return false;
    final q = _currentQuestion;
    switch (q.type) {
      case QuestionType.multipleChoice:
      case QuestionType.chooseCorrect:
        return _selectedOption != null;
      case QuestionType.trueFalse:
        return _tfAnswer != null;
      case QuestionType.fillInTheBlanks:
      case QuestionType.completeDialogue:
      case QuestionType.completeCode:
        return _blanksCtrls.every((c) => c.text.trim().isNotEmpty);
      case QuestionType.completeWord:
      case QuestionType.orderWords:
      case QuestionType.errorCorrection:
      case QuestionType.shortWriting:
        return _blanksCtrls.isNotEmpty && _blanksCtrls.first.text.trim().isNotEmpty;
      case QuestionType.matching:
        return _matchPairs.length == (q.matchingLeft?.length ?? 0);
      case QuestionType.miniReading:
        if (q.options != null && q.options!.isNotEmpty) return _selectedOption != null;
        return _blanksCtrls.isNotEmpty && _blanksCtrls.first.text.trim().isNotEmpty;
    }
  }

  void _submit() {
    final q = _currentQuestion;
    bool correct = false;

    switch (q.type) {
      case QuestionType.multipleChoice:
      case QuestionType.chooseCorrect:
        correct = q.options?.any((o) => o.text == _selectedOption && o.isCorrect) ?? false;
        break;
      case QuestionType.trueFalse:
        correct = _tfAnswer == q.correctAnswer;
        break;
      case QuestionType.fillInTheBlanks:
      case QuestionType.completeDialogue:
      case QuestionType.completeCode:
        if (q.blanksAnswers != null) {
          correct = true;
          for (int i = 0; i < q.blanksAnswers!.length; i++) {
            if (i >= _blanksCtrls.length) { correct = false; break; }
            if (_blanksCtrls[i].text.trim().toLowerCase() !=
                q.blanksAnswers![i].trim().toLowerCase()) {
              correct = false;
              break;
            }
          }
        }
        break;
      case QuestionType.completeWord:
        correct = _blanksCtrls.first.text.trim().toLowerCase() ==
            (q.correctAnswer ?? '').trim().toLowerCase();
        break;
      case QuestionType.orderWords:
      case QuestionType.errorCorrection:
        // Aceptar si la respuesta contiene las palabras clave del correctAnswer
        final expected = (q.correctAnswer ?? '').toLowerCase();
        final given = _blanksCtrls.first.text.trim().toLowerCase();
        correct = expected.isNotEmpty && given == expected;
        break;
      case QuestionType.shortWriting:
        correct = true; // Escritura libre: siempre correcto si escribió algo
        break;
      case QuestionType.matching:
        correct = true;
        for (int i = 0; i < (q.matchingLeft?.length ?? 0); i++) {
          if (_matchPairs[i] != i) { correct = false; break; }
        }
        break;
      case QuestionType.miniReading:
        if (q.options != null && q.options!.isNotEmpty) {
          correct = q.options!.any((o) => o.text == _selectedOption && o.isCorrect);
        } else {
          correct = true; // respuesta libre: siempre correcto si escribió algo
        }
        break;
    }

    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) _correctCount++;
    });

    _showFeedback();
  }

  void _showFeedback() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeedbackSheet(
        isCorrect: _isCorrect,
        question: _currentQuestion,
        onContinue: () {
          Navigator.pop(context);
          _advance();
        },
      ),
    );
  }

  void _advance() {
    if (_currentIndex >= _total - 1) {
      _showCompletion();
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _isCorrect = false;
    });
    _prepareQuestion();
  }

  Future<void> _showCompletion() async {
    final xp = _level?.xpReward ?? 100;

    // Bug #2 fix: await and catch errors so the user knows if the save failed.
    try {
      await ref
          .read(progressProvider.notifier)
          .completeLevel(widget.courseIndex, widget.levelId, xp);
    } catch (e) {
      debugPrint('[LessonScreen] Failed to save progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ No se pudo guardar el progreso. Revisa tu conexión.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompletionDialog(
        correctCount: _correctCount,
        total: _total,
        xpReward: xp,
        onContinue: () {
          Navigator.pop(context);
          context.go('/');
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _blanksCtrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.go('/'))),
        body: const Center(child: Text('Nivel no encontrado')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final progress = (_currentIndex + 1) / _total;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurfaceVariant),
          onPressed: () => context.go('/'),
        ),
        title: LinearProgressIndicator(
          value: progress,
          backgroundColor: cs.surfaceContainerHighest,
          color: cs.primary,
          minHeight: 12,
          borderRadius: BorderRadius.circular(8),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_currentIndex + 1}/$_total',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildBody(cs),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  disabledBackgroundColor: cs.surfaceContainerHighest,
                  disabledForegroundColor: cs.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: _canSubmit ? 4 : 0,
                ),
                child: const Text(
                  'COMPROBAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    final q = _currentQuestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _QuestionHeader(question: q, cs: cs),
        const SizedBox(height: 28),
        _buildQuestionInput(q, cs),
      ],
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildQuestionInput(Question q, ColorScheme cs) {
    switch (q.type) {
      case QuestionType.multipleChoice:
      case QuestionType.chooseCorrect:
        return _MultipleChoiceBody(
          options: q.options ?? [],
          selected: _selectedOption,
          answered: _answered,
          isCorrect: _isCorrect,
          onSelect: (v) => setState(() => _selectedOption = v),
          cs: cs,
        );
      case QuestionType.trueFalse:
        return _TrueFalseBody(
          selected: _tfAnswer,
          answered: _answered,
          correctAnswer: q.correctAnswer ?? 'true',
          onSelect: (v) => setState(() => _tfAnswer = v),
          cs: cs,
        );
      case QuestionType.fillInTheBlanks:
      case QuestionType.completeDialogue:
        return _FillInTheBlanksBody(
          instruction: q.instruction ?? q.prompt,
          controllers: _blanksCtrls,
          answered: _answered,
          correctAnswers: q.blanksAnswers ?? [],
          cs: cs,
          onChanged: () => setState(() {}),
        );
      case QuestionType.completeCode:
        return _CompleteCodeBody(
          snippet: q.codeSnippet ?? '',
          language: q.codeLanguage ?? 'code',
          controllers: _blanksCtrls,
          answered: _answered,
          correctAnswers: q.blanksAnswers ?? [],
          cs: cs,
          onChanged: () => setState(() {}),
        );
      case QuestionType.completeWord:
        return _SingleTextBody(
          hint: 'Escribe la respuesta...',
          controller: _blanksCtrls.isNotEmpty ? _blanksCtrls.first : TextEditingController(),
          answered: _answered,
          correctAnswer: q.correctAnswer ?? '',
          cs: cs,
          onChanged: () => setState(() {}),
        );
      case QuestionType.orderWords:
        return _OrderWordsBody(
          instruction: q.instruction ?? '',
          controller: _blanksCtrls.isNotEmpty ? _blanksCtrls.first : TextEditingController(),
          answered: _answered,
          correctAnswer: q.correctAnswer ?? '',
          cs: cs,
          onChanged: () => setState(() {}),
        );
      case QuestionType.errorCorrection:
        return _SingleTextBody(
          hint: 'Escribe la corrección...',
          controller: _blanksCtrls.isNotEmpty ? _blanksCtrls.first : TextEditingController(),
          answered: _answered,
          correctAnswer: q.correctAnswer ?? '',
          cs: cs,
          onChanged: () => setState(() {}),
        );
      case QuestionType.shortWriting:
        return _SingleTextBody(
          hint: 'Escribe tu respuesta...',
          controller: _blanksCtrls.isNotEmpty ? _blanksCtrls.first : TextEditingController(),
          answered: _answered,
          correctAnswer: '',
          cs: cs,
          onChanged: () => setState(() {}),
          maxLines: 4,
          alwaysCorrect: true,
        );
      case QuestionType.matching:
        return _MatchingBody(
          leftItems: q.matchingLeft ?? [],
          rightItems: q.matchingRight ?? [],
          rightOrder: _matchRightOrder,
          selectedLeft: _matchSelectedLeft,
          pairs: _matchPairs,
          answered: _answered,
          isCorrect: _isCorrect,
          onSelectLeft: (i) => setState(() => _matchSelectedLeft = i),
          onSelectRight: (rightDisplayIdx) {
            if (_matchSelectedLeft == null) return;
            final rightOrigIdx = _matchRightOrder[rightDisplayIdx];
            setState(() {
              _matchPairs = Map.from(_matchPairs)..[_matchSelectedLeft!] = rightOrigIdx;
              _matchSelectedLeft = null;
            });
          },
          cs: cs,
        );
      case QuestionType.miniReading:
        return _MiniReadingBody(
          readingText: q.readingText ?? '',
          instruction: q.instruction ?? '',
          options: q.options,
          selected: _selectedOption,
          answered: _answered,
          isCorrect: _isCorrect,
          onSelect: (v) => setState(() => _selectedOption = v),
          controller: _blanksCtrls.isNotEmpty ? _blanksCtrls.first : null,
          onChanged: () => setState(() {}),
          cs: cs,
        );
    }
  }
}

// ─────────────────────────────────────────────
//  CABECERA DE PREGUNTA
// ─────────────────────────────────────────────
class _QuestionHeader extends StatelessWidget {
  final Question question;
  final ColorScheme cs;
  const _QuestionHeader({required this.question, required this.cs});

  @override
  Widget build(BuildContext context) {
    final q = question;
    final label = _typeLabel(q.type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Text(q.prompt,
            style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.bold,
                height: 1.3)),
      ],
    );
  }

  String _typeLabel(QuestionType t) {
    switch (t) {
      case QuestionType.multipleChoice: return 'SELECCIÓN MÚLTIPLE';
      case QuestionType.trueFalse: return 'VERDADERO O FALSO';
      case QuestionType.fillInTheBlanks: return 'COMPLETA LOS ESPACIOS';
      case QuestionType.matching: return 'RELACIONA LAS COLUMNAS';
      case QuestionType.orderWords: return 'ORDENA LAS PALABRAS';
      case QuestionType.errorCorrection: return 'CORRIGE EL ERROR';
      case QuestionType.shortWriting: return 'ESCRITURA LIBRE';
      case QuestionType.miniReading: return 'COMPRENSIÓN DE LECTURA';
      case QuestionType.completeDialogue: return 'COMPLETA EL DIÁLOGO';
      case QuestionType.chooseCorrect: return 'ELIGE LA CORRECTA';
      case QuestionType.completeCode: return 'COMPLETA EL CÓDIGO';
      case QuestionType.completeWord: return 'COMPLETA LA PALABRA';
    }
  }
}

// ─────────────────────────────────────────────
//  SELECCIÓN MÚLTIPLE
// ─────────────────────────────────────────────
class _MultipleChoiceBody extends StatelessWidget {
  final List<QuestionOption> options;
  final String? selected;
  final bool answered;
  final bool isCorrect;
  final ValueChanged<String> onSelect;
  final ColorScheme cs;

  const _MultipleChoiceBody({
    required this.options, required this.selected, required this.answered,
    required this.isCorrect, required this.onSelect, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        Color bg = cs.surfaceContainerHighest.withOpacity(0.6);
        Color border = cs.outline.withOpacity(0.2);
        Color text = cs.onSurface;

        if (selected == opt.text) {
          if (!answered) {
            bg = cs.primaryContainer;
            border = cs.primary;
            text = cs.onPrimaryContainer;
          } else if (opt.isCorrect) {
            bg = Colors.green.shade100;
            border = Colors.green;
            text = Colors.green.shade900;
          } else {
            bg = Colors.red.shade100;
            border = Colors.red;
            text = Colors.red.shade900;
          }
        } else if (answered && opt.isCorrect) {
          bg = Colors.green.shade100;
          border = Colors.green;
          text = Colors.green.shade900;
        }

        return GestureDetector(
          onTap: answered ? null : () => onSelect(opt.text),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                Expanded(child: Text(opt.text, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w500))),
                if (answered && selected == opt.text)
                  Icon(opt.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: opt.isCorrect ? Colors.green : Colors.red, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  VERDADERO / FALSO
// ─────────────────────────────────────────────
class _TrueFalseBody extends StatelessWidget {
  final String? selected;
  final bool answered;
  final String correctAnswer;
  final ValueChanged<String> onSelect;
  final ColorScheme cs;

  const _TrueFalseBody({
    required this.selected, required this.answered, required this.correctAnswer,
    required this.onSelect, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _btn('true', 'VERDADERO', Icons.check_circle_outline)),
        const SizedBox(width: 12),
        Expanded(child: _btn('false', 'FALSO', Icons.cancel_outlined)),
      ],
    );
  }

  Widget _btn(String value, String label, IconData icon) {
    final isSelected = selected == value;
    Color bg = cs.surfaceContainerHighest.withOpacity(0.6);
    Color border = cs.outline.withOpacity(0.3);
    Color fg = cs.onSurface;

    if (isSelected) {
      if (!answered) {
        bg = cs.primaryContainer;
        border = cs.primary;
        fg = cs.onPrimaryContainer;
      } else if (value == correctAnswer) {
        bg = Colors.green.shade100; border = Colors.green; fg = Colors.green.shade900;
      } else {
        bg = Colors.red.shade100; border = Colors.red; fg = Colors.red.shade900;
      }
    } else if (answered && value == correctAnswer) {
      bg = Colors.green.shade100; border = Colors.green; fg = Colors.green.shade900;
    }

    return GestureDetector(
      onTap: answered ? null : () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2)),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COMPLETAR ESPACIOS
// ─────────────────────────────────────────────
class _FillInTheBlanksBody extends StatelessWidget {
  final String instruction;
  final List<TextEditingController> controllers;
  final bool answered;
  final List<String> correctAnswers;
  final ColorScheme cs;
  final VoidCallback onChanged;

  const _FillInTheBlanksBody({
    required this.instruction, required this.controllers, required this.answered,
    required this.correctAnswers, required this.cs, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withOpacity(0.2)),
          ),
          child: Text(instruction,
              style: TextStyle(color: cs.onSurface, fontSize: 16, height: 1.5)),
        ),
        const SizedBox(height: 20),
        ...List.generate(controllers.length, (i) => _blankField(i)),
      ],
    );
  }

  Widget _blankField(int i) {
    final isCorrect = answered && i < correctAnswers.length &&
        controllers[i].text.trim().toLowerCase() == correctAnswers[i].trim().toLowerCase();
    final isWrong = answered && !isCorrect;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controllers[i],
        readOnly: answered,
        onChanged: (_) => onChanged(),
        style: TextStyle(color: cs.onSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Espacio ${i + 1}',
          hintText: answered && i < correctAnswers.length ? correctAnswers[i] : null,
          suffixIcon: answered
              ? Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red)
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isWrong ? Colors.red : Colors.green, width: 2),
          ),
          filled: true,
          fillColor: answered
              ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
              : cs.surfaceContainerHighest.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COMPLETAR CÓDIGO
// ─────────────────────────────────────────────
class _CompleteCodeBody extends StatelessWidget {
  final String snippet;
  final String language;
  final List<TextEditingController> controllers;
  final bool answered;
  final List<String> correctAnswers;
  final ColorScheme cs;
  final VoidCallback onChanged;

  const _CompleteCodeBody({
    required this.snippet, required this.language, required this.controllers,
    required this.answered, required this.correctAnswers, required this.cs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(language.toUpperCase(),
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(snippet,
                    style: const TextStyle(color: Color(0xFFCDD6F4),
                        fontFamily: 'monospace', fontSize: 16, height: 1.6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Completa los espacios en blanco:',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
        const SizedBox(height: 12),
        ...List.generate(controllers.length, (i) {
          final isCorrect = answered && i < correctAnswers.length &&
              controllers[i].text.trim().toLowerCase() == correctAnswers[i].trim().toLowerCase();
          final isWrong = answered && !isCorrect;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controllers[i],
              readOnly: answered,
              onChanged: (_) => onChanged(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Espacio ${i + 1}',
                suffixIcon: answered
                    ? Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red)
                    : null,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline.withOpacity(0.4))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: isWrong ? Colors.red : Colors.green, width: 2)),
                filled: true,
                fillColor: answered
                    ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                    : cs.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  CAMPO DE TEXTO ÚNICO (completeWord, orderWords, etc.)
// ─────────────────────────────────────────────
class _SingleTextBody extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool answered;
  final String correctAnswer;
  final ColorScheme cs;
  final VoidCallback onChanged;
  final int maxLines;
  final bool alwaysCorrect;

  const _SingleTextBody({
    required this.hint, required this.controller, required this.answered,
    required this.correctAnswer, required this.cs, required this.onChanged,
    this.maxLines = 1, this.alwaysCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = alwaysCorrect ||
        (answered && controller.text.trim().toLowerCase() == correctAnswer.trim().toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (correctAnswer.isNotEmpty && !answered) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Escribe exactamente la respuesta correcta',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: controller,
          readOnly: answered,
          onChanged: (_) => onChanged(),
          maxLines: maxLines,
          style: TextStyle(color: cs.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: answered
                ? Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red)
                : null,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outline.withOpacity(0.4))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 2)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isCorrect ? Colors.green : Colors.red, width: 2)),
            filled: true,
            fillColor: answered
                ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                : cs.surfaceContainerHighest.withOpacity(0.3),
          ),
        ),
        if (answered && !isCorrect && correctAnswer.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Respuesta correcta: $correctAnswer',
              style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ORDENAR PALABRAS
// ─────────────────────────────────────────────
class _OrderWordsBody extends StatelessWidget {
  final String instruction;
  final TextEditingController controller;
  final bool answered;
  final String correctAnswer;
  final ColorScheme cs;
  final VoidCallback onChanged;

  const _OrderWordsBody({
    required this.instruction, required this.controller, required this.answered,
    required this.correctAnswer, required this.cs, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = answered &&
        controller.text.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.2)),
          ),
          child: Text(instruction,
              style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.5)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          readOnly: answered,
          onChanged: (_) => onChanged(),
          maxLines: 2,
          style: TextStyle(color: cs.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Escribe las frases ordenadas...',
            suffixIcon: answered
                ? Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red)
                : null,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outline.withOpacity(0.4))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 2)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isCorrect ? Colors.green : Colors.red, width: 2)),
            filled: true,
            fillColor: answered
                ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                : cs.surfaceContainerHighest.withOpacity(0.3),
          ),
        ),
        if (answered && !isCorrect && correctAnswer.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Respuesta correcta: $correctAnswer',
              style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  RELACIONAR COLUMNAS
// ─────────────────────────────────────────────
class _MatchingBody extends StatelessWidget {
  final List<String> leftItems;
  final List<String> rightItems;
  final List<int> rightOrder;
  final int? selectedLeft;
  final Map<int, int> pairs;
  final bool answered;
  final bool isCorrect;
  final ValueChanged<int> onSelectLeft;
  final ValueChanged<int> onSelectRight;
  final ColorScheme cs;

  const _MatchingBody({
    required this.leftItems, required this.rightItems, required this.rightOrder,
    required this.selectedLeft, required this.pairs, required this.answered,
    required this.isCorrect, required this.onSelectLeft, required this.onSelectRight,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Toca un elemento de la izquierda y luego su par de la derecha.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildColumn(true)),
            const SizedBox(width: 12),
            Expanded(child: _buildColumn(false)),
          ],
        ),
      ],
    );
  }

  Widget _buildColumn(bool isLeft) {
    final count = isLeft ? leftItems.length : rightOrder.length;
    return Column(
      children: List.generate(count, (displayIdx) {
        if (isLeft) return _leftItem(displayIdx);
        return _rightItem(displayIdx);
      }),
    );
  }

  Widget _leftItem(int i) {
    final isPaired = pairs.containsKey(i);
    final isSelected = selectedLeft == i;
    Color bg = cs.surfaceContainerHighest.withOpacity(0.5);
    Color border = cs.outline.withOpacity(0.2);

    if (answered) {
      border = (pairs[i] == i) ? Colors.green : Colors.red;
      bg = (pairs[i] == i) ? Colors.green.shade50 : Colors.red.shade50;
    } else if (isSelected) {
      bg = cs.primaryContainer;
      border = cs.primary;
    } else if (isPaired) {
      bg = cs.tertiaryContainer;
      border = cs.tertiary;
    }

    return GestureDetector(
      onTap: answered ? null : () => onSelectLeft(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(leftItems[i],
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _rightItem(int displayIdx) {
    final origIdx = rightOrder[displayIdx];
    final isPaired = pairs.values.contains(origIdx);
    final pairedLeftIdx = pairs.entries
        .where((e) => e.value == origIdx)
        .map((e) => e.key)
        .firstOrNull;
    final isCorrectPair = answered && pairedLeftIdx != null && pairedLeftIdx == origIdx;
    final isWrongPair = answered && pairedLeftIdx != null && pairedLeftIdx != origIdx;

    Color bg = cs.surfaceContainerHighest.withOpacity(0.5);
    Color border = cs.outline.withOpacity(0.2);
    if (answered) {
      border = isCorrectPair ? Colors.green : (isWrongPair ? Colors.red : cs.outline.withOpacity(0.2));
      bg = isCorrectPair ? Colors.green.shade50 : (isWrongPair ? Colors.red.shade50 : bg);
    } else if (isPaired) {
      bg = cs.tertiaryContainer;
      border = cs.tertiary;
    }

    return GestureDetector(
      onTap: answered ? null : () => onSelectRight(displayIdx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(rightItems[origIdx],
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MINI LECTURA
// ─────────────────────────────────────────────
class _MiniReadingBody extends StatelessWidget {
  final String readingText;
  final String instruction;
  final List<QuestionOption>? options;
  final String? selected;
  final bool answered;
  final bool isCorrect;
  final ValueChanged<String> onSelect;
  final TextEditingController? controller;
  final VoidCallback? onChanged;
  final ColorScheme cs;

  const _MiniReadingBody({
    required this.readingText, required this.instruction, required this.options,
    required this.selected, required this.answered, required this.isCorrect,
    required this.onSelect, required this.cs,
    this.controller, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasOptions = options != null && options!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withOpacity(0.3)),
          ),
          child: Text(readingText,
              style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.6)),
        ),
        const SizedBox(height: 16),
        if (instruction.isNotEmpty)
          Text(instruction,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, height: 1.4)),
        const SizedBox(height: 16),
        if (hasOptions)
          _MultipleChoiceBody(
            options: options!, selected: selected, answered: answered,
            isCorrect: isCorrect, onSelect: onSelect, cs: cs,
          )
        else if (controller != null)
          TextField(
            controller: controller,
            enabled: !answered,
            maxLines: 4,
            onChanged: (_) => onChanged?.call(),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta aquí...',
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM SHEET DE FEEDBACK
// ─────────────────────────────────────────────
class _FeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final Question question;
  final VoidCallback onContinue;

  const _FeedbackSheet({required this.isCorrect, required this.question, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final bg = isCorrect ? Colors.green.shade50 : Colors.red.shade50;
    final border = isCorrect ? Colors.green.shade300 : Colors.red.shade300;
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final iconColor = isCorrect ? Colors.green : Colors.red;
    final title = isCorrect ? '¡Excelente!' : '¡Casi!';
    final btnColor = isCorrect ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 36),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: iconColor)),
            ],
          ),
          const SizedBox(height: 12),
          if (!isCorrect)
            Text(
              _correctAnswerText(),
              style: TextStyle(color: Colors.red.shade800, fontSize: 15),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: onContinue,
            child: Text(isCorrect ? 'CONTINUAR' : 'SIGUIENTE',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _correctAnswerText() {
    final q = question;
    if (q.correctAnswer != null && q.correctAnswer!.isNotEmpty) {
      return 'Respuesta correcta: ${q.correctAnswer}';
    }
    if (q.options != null) {
      final correct = q.options!.where((o) => o.isCorrect).map((o) => o.text).join(', ');
      if (correct.isNotEmpty) return 'Respuesta correcta: $correct';
    }
    if (q.blanksAnswers != null && q.blanksAnswers!.isNotEmpty) {
      return 'Respuesta correcta: ${q.blanksAnswers!.join(' / ')}';
    }
    if (q.matchingLeft != null && q.matchingRight != null) {
      final pairs = List.generate(
          q.matchingLeft!.length, (i) => '${q.matchingLeft![i]} → ${q.matchingRight![i]}');
      return 'Pares correctos:\n${pairs.join('\n')}';
    }
    return 'Revisa la respuesta correcta.';
  }
}

// ─────────────────────────────────────────────
//  DIÁLOGO DE COMPLETADO
// ─────────────────────────────────────────────
class _CompletionDialog extends StatelessWidget {
  final int correctCount;
  final int total;
  final int xpReward;
  final VoidCallback onContinue;

  const _CompletionDialog({
    required this.correctCount, required this.total,
    required this.xpReward, required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (correctCount / total * 100).round();
    final isPerfect = correctCount == total;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isPerfect ? '🏆' : '🎯', style: const TextStyle(fontSize: 64))
                .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(isPerfect ? '¡Nivel perfecto!' : '¡Nivel completado!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('$correctCount de $total correctas ($pct%)',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statChip(context, '⭐', '+$xpReward XP', Colors.amber),
                const SizedBox(width: 12),
                _statChip(context, '🔥', '+1 racha', Colors.orange),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onContinue,
                child: const Text('CONTINUAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, String emoji, String label, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
